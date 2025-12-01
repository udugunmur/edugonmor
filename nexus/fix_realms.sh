#!/bin/bash
set -e

NEXUS_URL="http://localhost:8081"
NEXUS_USER="admin"
# We assume admin password is now admin123 or the one from file if it exists
if [ -f "./docker/volumes/nexus_volumen/admin.password" ]; then
    NEXUS_PASSWORD=$(cat "./docker/volumes/nexus_volumen/admin.password")
else
    NEXUS_PASSWORD="admin123"
fi

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }

log_info "Using Admin Password: $NEXUS_PASSWORD"

# 1. Deactivate DockerToken Realm
log_info "Deactivating DockerToken Realm..."
curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X PUT "$NEXUS_URL/service/rest/v1/security/realms/active" \
    -H "Content-Type: application/json" \
    -d '["NexusAuthenticatingRealm"]'

# 2. Reactivate DockerToken Realm (Force Refresh)
log_info "Reactivating DockerToken Realm..."
curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X PUT "$NEXUS_URL/service/rest/v1/security/realms/active" \
    -H "Content-Type: application/json" \
    -d '["NexusAuthenticatingRealm", "DockerToken"]'

log_info "Realms refreshed."
