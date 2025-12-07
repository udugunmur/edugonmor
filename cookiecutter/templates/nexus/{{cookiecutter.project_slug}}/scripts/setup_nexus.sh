#!/bin/bash
set -e

NEXUS_URL="http://localhost:{{cookiecutter._nexus_port}}"
NEXUS_USER="admin"
DATA_DIR="./docker/volumes/nexus_data" # Adjusted to match docker-compose volume

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# 1. Wait for Nexus to be ready
log_info "Waiting for Nexus to be ready at $NEXUS_URL..."
until curl -s -f -o /dev/null "$NEXUS_URL/service/rest/v1/status"; do
    echo -n "."
    sleep 5
done
echo ""
log_info "Nexus is online."




# 2. Get Admin Password
CONTAINER_NAME="{{cookiecutter.project_slug}}_services"
log_info "Attempting to retrieve admin.password from container ($CONTAINER_NAME)..."

if docker exec "$CONTAINER_NAME" test -f /nexus-data/admin.password; then
    NEXUS_PASSWORD=$(docker exec "$CONTAINER_NAME" cat /nexus-data/admin.password)
    log_info "✅ Found initial admin password."
else
    # Check if default 'admin123' works (idempotency for re-runs)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "$NEXUS_USER:admin123" "$NEXUS_URL/service/rest/v1/status")
    if [ "$HTTP_CODE" -eq 200 ]; then
        log_info "✅ Default password 'admin123' is valid."
        NEXUS_PASSWORD="admin123"
    else
        log_warn "admin.password missing and default 'admin123' failed. Script might fail."
        NEXUS_PASSWORD="admin123"
    fi
fi

# 2.5 Force-Update Admin Password to Match Template Configuration
DESIRED_PASSWORD="{{cookiecutter._nexus_password}}"
if [ "$NEXUS_PASSWORD" != "$DESIRED_PASSWORD" ]; then
    log_info "Updating Admin Password to match template configuration..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "$NEXUS_USER:$NEXUS_PASSWORD" -X PUT "$NEXUS_URL/service/rest/v1/security/users/$NEXUS_USER/change-password" \
        -H "Content-Type: text/plain" \
        -d "$DESIRED_PASSWORD")
    
    if [ "$HTTP_CODE" -eq 204 ] || [ "$HTTP_CODE" -eq 200 ]; then
        log_info "Password updated successfully."
        NEXUS_PASSWORD="$DESIRED_PASSWORD"
    else
        log_warn "Failed to update password (HTTP $HTTP_CODE). Continuing with detected password..."
    fi
else
    log_info "Password already matches template configuration."
fi

# 2.6 Accept EULA (Required for Docker Login)
log_info "Checking EULA status..."
EULA_JSON=$(curl -s -u "$NEXUS_USER:$NEXUS_PASSWORD" "$NEXUS_URL/service/rest/v1/system/eula")
if echo "$EULA_JSON" | grep -q '"accepted" : false'; then
    log_info "EULA not accepted. Attempting to accept..."
    # Replace "accepted" : false with "accepted" : true
    # We use python3 for robust JSON handling if available, or simple sed fallback
    # Since this is a simple boolean flip with known format from Nexus 3, simple sed is risky but likely sufficient if format is stable.
    # But wait, the previous sed command worked: sed -i 's/"accepted" : false/"accepted" : true/' eula.json
    
    # We will use a temporary file to be safe
    echo "$EULA_JSON" > /tmp/nexus_eula.json
    sed -i 's/"accepted" : false/"accepted" : true/' /tmp/nexus_eula.json
    
    HTTP_CODE_EULA=$(curl -s -o /dev/null -w "%{http_code}" -u "$NEXUS_USER:$NEXUS_PASSWORD" -X POST "$NEXUS_URL/service/rest/v1/system/eula" \
        -H "Content-Type: application/json" -d @/tmp/nexus_eula.json)
    
    rm /tmp/nexus_eula.json
    
    if [ "$HTTP_CODE_EULA" -eq 200 ] || [ "$HTTP_CODE_EULA" -eq 204 ]; then
        log_info "✅ EULA accepted successfully."
    else
        log_warn "Failed to accept EULA (HTTP $HTTP_CODE_EULA). Docker login might fail."
    fi
else
    log_info "✅ EULA already accepted."
fi

# 3. Create Docker Hosted Repository
REPO_NAME="docker-hosted"
log_info "Checking if repository '$REPO_NAME' exists..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "$NEXUS_USER:$NEXUS_PASSWORD" "$NEXUS_URL/service/rest/v1/repositories/docker/hosted/$REPO_NAME")

if [ "$HTTP_CODE" -eq 200 ]; then
    log_info "✅ Repository '$REPO_NAME' already exists. Skipping creation."
else
    log_info "Creating '$REPO_NAME' repository..."
    curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -s -f -X POST "$NEXUS_URL/service/rest/v1/repositories/docker/hosted" \
        -H "Content-Type: application/json" \
        -d '{
          "name": "'"$REPO_NAME"'",
          "online": true,
          "storage": {
            "blobStoreName": "default",
            "strictContentTypeValidation": true,
            "writePolicy": "ALLOW"
          },
          "docker": {
            "v1Enabled": false,
            "forceBasicAuth": true,
            "httpPort": {{cookiecutter._nexus_docker_port}}
          }
        }' || log_error "Failed to create repository."
fi

# 4. Enable Docker Bearer Token Realm
log_info "Enabling Docker Bearer Token Realm..."
ACTIVE_REALMS=$(curl -s -u "$NEXUS_USER:$NEXUS_PASSWORD" "$NEXUS_URL/service/rest/v1/security/realms/active")
if [[ "$ACTIVE_REALMS" != *"DockerToken"* ]]; then
    NEW_REALMS=$(echo "$ACTIVE_REALMS" | sed 's/]/, "DockerToken"]/')
    curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X PUT "$NEXUS_URL/service/rest/v1/security/realms/active" \
        -H "Content-Type: application/json" \
        -d "$NEW_REALMS"
else
    log_info "Docker Bearer Token Realm already active."
fi

log_info "Nexus configuration completed."
