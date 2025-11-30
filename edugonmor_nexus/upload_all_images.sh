#!/bin/bash
set -e

REGISTRY_URL="192.168.1.233:8082"
REPOS_DIR="/home/edugonmor/repos"

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }

# Load Secrets
SECRETS_DIR="/home/edugonmor/repos/edugonmor_nexus/docker/secrets"
if [ -f "$SECRETS_DIR/nexus_user.txt" ] && [ -f "$SECRETS_DIR/nexus_password.txt" ]; then
    NEXUS_USER=$(cat "$SECRETS_DIR/nexus_user.txt")
    NEXUS_PASS=$(cat "$SECRETS_DIR/nexus_password.txt")
else
    log_warn "Secrets not found. Please ensure docker/secrets/nexus_user.txt and nexus_password.txt exist."
    exit 1
fi

# Login to Docker Registry
log_info "Logging in to $REGISTRY_URL as $NEXUS_USER..."
echo "$NEXUS_PASS" | docker login "$REGISTRY_URL" -u "$NEXUS_USER" --password-stdin

# Check if logged in
if ! docker info | grep -q "$REGISTRY_URL"; then
    log_warn "It seems you are not logged in to $REGISTRY_URL or it is not configured as insecure-registry."
    log_info "Please run: docker login $REGISTRY_URL"
    # We continue, assuming user might have logged in but docker info output varies
fi

# Iterate over directories
for repo in "$REPOS_DIR"/*; do
    if [ -d "$repo" ]; then
        repo_name=$(basename "$repo")
        
        # Skip nexus itself to avoid loops or issues
        if [ "$repo_name" == "edugonmor_nexus" ]; then
            continue
        fi

        # Filter: Only process repos starting with "edugon" (covers edugonmor_, edugonmor_, etc.)
        if [[ "$repo_name" != edugon* ]]; then
            log_info "Skipping $repo_name (does not match prefix 'edugon')..."
            continue
        fi

        if [ -f "$repo/docker-compose.yml" ]; then
            log_info "Processing $repo_name..."
            
            cd "$repo"
            
            # 1. Build images
            log_info "Building images for $repo_name..."
            docker compose build || log_warn "Build failed for $repo_name, skipping..."

            # 2. Find images defined in this compose
            services=$(docker compose config --services)
            
            for service in $services; do
                log_info "  Service: $service"
                
                # Try to detect the image name.
                # 1. Check if 'image' property is set in docker-compose
                # We use a simple grep/awk heuristic or assume build naming convention if missing.
                
                # Attempt to get explicit image name from config
                # Note: This is a bit fragile without yq/jq, but works for standard files
                explicit_image=$(grep -A 5 "$service:" docker-compose.yml | grep "image:" | awk '{print $2}')
                
                if [ -n "$explicit_image" ]; then
                    source_image="$explicit_image"
                else
                    # 2. If built, Compose V2 usually names it "project-service" or "project_service"
                    # The project name is the directory name.
                    project_name=$(basename "$PWD")
                    
                    # Try hyphen first (standard V2)
                    source_image="${project_name}-${service}"
                    
                    if ! docker image inspect "$source_image" >/dev/null 2>&1; then
                        # Try underscore (older V1 or specific configs)
                        source_image="${project_name}_${service}"
                    fi
                    
                    if ! docker image inspect "$source_image" >/dev/null 2>&1; then
                         # Try just the service name (rare)
                         source_image="$service"
                    fi
                fi

                # Verify we found a valid image
                if ! docker image inspect "$source_image" >/dev/null 2>&1; then
                    log_warn "    Could not find local image '$source_image' for service '$service'. Skipping..."
                    continue
                fi
                
                # Tag and Push
                target_tag="$REGISTRY_URL/$repo_name/$service:latest"
                log_info "    Tagging $source_image -> $target_tag"
                docker tag "$source_image" "$target_tag"
                
                log_info "    Pushing $target_tag..."
                docker push "$target_tag"
            done
            
        else
            log_warn "No docker-compose.yml in $repo_name, skipping."
        fi
    fi
done
