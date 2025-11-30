#!/bin/bash
set -euo pipefail

# ============================================================================
# Nexus Backup Script
# ============================================================================
# Description: Creates a backup of NEXUS_DATA and manages retention.
# Usage: ./backup.sh
# Environment Variables:
#   - NEXUS_DATA: Path to Nexus data directory (default: /nexus-data)
#   - BACKUP_KEEP_DAYS: Number of days to keep backups (default: 7)
# ============================================================================

# Configuration
NEXUS_DATA="${NEXUS_DATA:-/nexus-data}"
BACKUP_ROOT="${NEXUS_DATA}/backups"
RETENTION_DAYS="${BACKUP_KEEP_DAYS:-7}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_ROOT}/nexus_data_${TIMESTAMP}.tar.gz"

# Logging functions
log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

log_info "Starting Nexus Data backup..."
log_info "Source: ${NEXUS_DATA}"
log_info "Destination: ${BACKUP_FILE}"
log_info "Retention Policy: Keep backups for ${RETENTION_DAYS} days"

# Ensure backup directory exists
if [ ! -d "${BACKUP_ROOT}" ]; then
    log_info "Creating backup directory: ${BACKUP_ROOT}"
    mkdir -p "${BACKUP_ROOT}"
    # Nexus UID is usually 200
    chown 200:200 "${BACKUP_ROOT}"
fi

# Create backup
log_info "Creating tarball..."

# Tar returns 1 on 'file changed as we read it', which is common on live systems.
# We temporarily disable strict error checking for the tar command
set +e
tar -czf "${BACKUP_FILE}" \
    --exclude "./backups" \
    --exclude "./log" \
    --exclude "./tmp" \
    --exclude "./cache" \
    --exclude "./lock" \
    --exclude "./db/accesslog" \
    -C "${NEXUS_DATA}" .
TAR_EXIT=$?
set -e

if [ $TAR_EXIT -eq 0 ] || [ $TAR_EXIT -eq 1 ]; then
    log_info "Backup created successfully: ${BACKUP_FILE}"
    chown 200:200 "${BACKUP_FILE}"
else
    log_error "Backup failed with exit code $TAR_EXIT"
    # Remove partial file if failed
    rm -f "${BACKUP_FILE}"
    exit 1
fi

# Prune old backups
log_info "Pruning backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_ROOT}" -name "nexus_data_*.tar.gz" -type f -mtime +"${RETENTION_DAYS}" -print -delete | while read -r file; do
    log_info "Deleted old backup: $file"
done

log_info "Backup process completed successfully."
