#!/bin/bash
set -e

NEXUS_URL="http://localhost:8081"
NEXUS_USER="admin"
DATA_DIR="./docker/volumes/nexus_volumen"

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# 1. Wait for Nexus to be ready
log_info "Waiting for Nexus to be ready..."
until curl -s -f -o /dev/null "$NEXUS_URL/service/rest/v1/status"; do
    echo -n "."
    sleep 5
done
echo ""
log_info "Nexus is online."

# 2. Get Admin Password
if [ -f "$DATA_DIR/admin.password" ]; then
    NEXUS_PASSWORD=$(cat "$DATA_DIR/admin.password")
    log_info "Found initial admin password."
else
    # If password file is gone, maybe it was already changed? 
    # For this script, we assume initial setup or we need the user to provide it.
    # We'll try 'admin123' as a fallback or ask user.
    # But for automation, let's assume we can read it or it's the default.
    log_error "admin.password file not found. Have you logged in and changed it? Using 'admin123' as fallback."
    NEXUS_PASSWORD="admin123"
fi

# 3. Create Docker Hosted Repository
log_info "Creating 'docker-hosted' repository on port 8082..."
curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X POST "$NEXUS_URL/service/rest/v1/repositories/docker/hosted" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "docker-hosted",
      "online": true,
      "storage": {
        "blobStoreName": "default",
        "strictContentTypeValidation": true,
        "writePolicy": "ALLOW"
      },
      "docker": {
        "v1Enabled": false,
        "forceBasicAuth": true,
        "httpPort": 8082
      }
    }' || log_error "Failed to create repo (it might already exist)."

# 4. Enable Docker Bearer Token Realm (Crucial for docker login)
log_info "Enabling Docker Bearer Token Realm..."
# First get current active realms
ACTIVE_REALMS=$(curl -s -u "$NEXUS_USER:$NEXUS_PASSWORD" "$NEXUS_URL/service/rest/v1/security/realms/active")
# Check if DockerToken is already active
if [[ "$ACTIVE_REALMS" != *"DockerToken"* ]]; then
    # Add DockerToken to the list
    NEW_REALMS=$(echo "$ACTIVE_REALMS" | sed 's/]/, "DockerToken"]/')
    curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X PUT "$NEXUS_URL/service/rest/v1/security/realms/active" \
        -H "Content-Type: application/json" \
        -d "$NEW_REALMS"
else
    log_info "Docker Bearer Token Realm already active."
fi

# 5. Create Custom User from Secrets
SECRETS_DIR="./docker/secrets"
if [ -f "$SECRETS_DIR/nexus_user.txt" ] && [ -f "$SECRETS_DIR/nexus_password.txt" ]; then
    CUSTOM_USER=$(cat "$SECRETS_DIR/nexus_user.txt")
    CUSTOM_PASS=$(cat "$SECRETS_DIR/nexus_password.txt")
    
    log_info "Creating/Updating custom user: $CUSTOM_USER..."
    
    # Check if user exists
    if curl -s -u "$NEXUS_USER:$NEXUS_PASSWORD" -f "$NEXUS_URL/service/rest/v1/security/users/$CUSTOM_USER" >/dev/null; then
        log_info "User $CUSTOM_USER already exists. Updating..."
        curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X PUT "$NEXUS_URL/service/rest/v1/security/users/$CUSTOM_USER" \
            -H "Content-Type: application/json" \
            -d "{
              \"userId\": \"$CUSTOM_USER\",
              \"firstName\": \"Edugonmor\",
              \"lastName\": \"Nexus\",
              \"emailAddress\": \"nexus@edugonmor.local\",
              \"password\": \"$CUSTOM_PASS\",
              \"status\": \"active\",
              \"roles\": [\"nx-admin\"]
            }"
    else
        log_info "Creating new user $CUSTOM_USER..."
        curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X POST "$NEXUS_URL/service/rest/v1/security/users" \
            -H "Content-Type: application/json" \
            -d "{
              \"userId\": \"$CUSTOM_USER\",
              \"firstName\": \"Edugonmor\",
              \"lastName\": \"Nexus\",
              \"emailAddress\": \"nexus@edugonmor.local\",
              \"password\": \"$CUSTOM_PASS\",
              \"status\": \"active\",
              \"roles\": [\"nx-admin\"]
            }"
    fi
else
    log_warn "Secrets files not found in $SECRETS_DIR. Skipping custom user creation."
fi

log_info "Nexus configuration completed."
