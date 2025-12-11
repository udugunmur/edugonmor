#!/bin/bash
set -e

# Configuration
BACKUP_DIR="/backups"
DATA_DIR="/app"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"

echo "Starting backup of ${DATA_DIR} to ${BACKUP_FILE}..."

# Create backup of app directory (source code + node_modules)
# Exclude dist and .cache
tar -czf "${BACKUP_FILE}" \
    --exclude="node_modules/.cache" \
    --exclude="dist" \
    -C / \
    app

echo "Backup created successfully: ${BACKUP_FILE}"

# Cleanup old backups (Keep last 7 by default)
find "${BACKUP_DIR}" -name "backup_*.tar.gz" -type f -mtime +7 -delete
echo "Cleanup complete."
