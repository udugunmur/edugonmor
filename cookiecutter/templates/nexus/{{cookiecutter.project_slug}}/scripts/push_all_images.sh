#!/bin/bash
set -e

# Configuration
REGISTRY_URL="localhost:{{cookiecutter._nexus_docker_port}}"
# Assuming script runs from project/scripts/, repositories are in ../..
REPOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }

# Load Credentials from env or defaults
NEXUS_USER="{{cookiecutter._nexus_user}}"
NEXUS_PASS="{{cookiecutter._nexus_password}}"

# Login to Docker Registry
log_info "Logging in to $REGISTRY_URL as $NEXUS_USER..."
echo "$NEXUS_PASS" | docker login "$REGISTRY_URL" -u "$NEXUS_USER" --password-stdin

# Iterate over directories in the parent repos folder
for repo in "$REPOS_DIR"/*; do
    if [ -d "$repo" ]; then
        repo_name=$(basename "$repo")
        
        # Skip nexus project itself if currently running to avoid feedback loop, unless intended
        if [[ "$repo_name" == *"nexus"* ]]; then
            continue
        fi

        if [ -f "$repo/docker-compose.yml" ]; then
            log_info "Processing $repo_name..."
            
            cd "$repo"
            
            # 1. Build images
            log_info "Building images for $repo_name..."
            docker compose build || log_warn "Build failed for $repo_name, skipping..."

            # 2. Find images defined in this compose
            # (Simplified heuristics used in original script)
            services=$(docker compose config --services)
            
            for service in $services; do
                # Determine image name (simplified)
                project_name=$(basename "$PWD")
                source_image="${project_name}-${service}"
                
                # Try fallback names if simple convention fails
                if ! docker image inspect "$source_image" >/dev/null 2>&1; then
                    source_image="${project_name}_${service}"
                fi
                
                if docker image inspect "$source_image" >/dev/null 2>&1; then
                    # Tag and Push
                    target_tag="$REGISTRY_URL/$repo_name/$service:latest"
                    log_info "    Pushing $target_tag..."
                    docker tag "$source_image" "$target_tag"
                    docker push "$target_tag"
                else
                     log_warn "    Could not find local image '$source_image' for service '$service'. Skipping..."
                fi
            done
            cd - > /dev/null
        fi
    fi
done
