#!/bin/bash
set -e

# Configuración
TIMESTAMP=$(date +"%d%m%Y_%H%M%S")
BACKUP_DIR="/backups"
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql.gz"

echo "[$(date)] Iniciando backup de MySQL..."

# Ejecutar backup (mysqldump --all-databases)
# Importante: --single-transaction para InnoDB
mysqldump \
    -h "${MYSQL_HOST}" \
    -u "${MYSQL_USER}" \
    -p"${MYSQL_PASS}" \
    --all-databases \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    | gzip > "${BACKUP_FILE}"

echo "[$(date)] Backup completado: ${BACKUP_FILE}"

# Rotación de backups (mantener últimos N días)
if [ -n "${BACKUP_RETENTION}" ]; then
    echo "[$(date)] Limpiando backups antiguos (Retención: ${BACKUP_RETENTION} días)..."
    find "${BACKUP_DIR}" -name "backup_*.sql.gz" -mtime +"${BACKUP_RETENTION}" -delete
fi

echo "[$(date)] Proceso finalizado."
