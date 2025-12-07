#!/bin/bash
set -e
set -o pipefail

# Configuración
TIMESTAMP=$(date +"%d%m%Y_%H%M%S")
BACKUP_DIR="/backups"
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql.gz"

echo "[$(date)] Iniciando backup de PostgreSQL..."

# Ejecutar backup (pg_dumpall para cluster completo)
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dumpall \
    -h "${POSTGRES_HOST}" \
    -U "${POSTGRES_USER}" \
    --clean \
    --if-exists \
    | gzip > "${BACKUP_FILE}"

echo "[$(date)] Backup completado: ${BACKUP_FILE}"

# Rotación de backups (mantener últimos N días)
if [ -n "${BACKUP_RETENTION}" ]; then
    echo "[$(date)] Limpiando backups antiguos (Retención: ${BACKUP_RETENTION} días)..."
    find "${BACKUP_DIR}" -name "backup_*.sql.gz" -mtime +"${BACKUP_RETENTION}" -delete
fi

echo "[$(date)] Proceso finalizado."
