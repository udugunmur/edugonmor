#!/bin/bash
#
# backup.sh - Script de backup manual
#

set -e

BACKUP_DIR="${BACKUP_DIR:-/backup}"
SOURCE_DIR="${SOURCE_DIR:-/source}"
RETENTION_DAYS="${RETENTION_DAYS:-10}"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="portainer-data-backup-manual-${TIMESTAMP}.tar.gz"

echo "Creando backup: $BACKUP_FILE"
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" -C "$SOURCE_DIR" .

echo "Limpiando backups antiguos..."
find "$BACKUP_DIR" -name "portainer-data-backup-*" -mtime +${RETENTION_DAYS} -delete

echo "Backup completado."
