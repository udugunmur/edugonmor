#!/bin/bash
# ============================================================================
# MariaDB {{cookiecutter._mariadb_version}} - Backup Script (mariadb-dump)
# ============================================================================
# Documentación: https://mariadb.com/docs/server/server-usage/backup-and-restore/backup-and-restore-overview/#mariadb-dump
# Herramienta: mariadb-dump (oficial MariaDB)
# ============================================================================

set -e
set -o pipefail

# Variables de entorno (inyectadas desde docker-compose)
MARIADB_HOST="${MARIADB_HOST:-{{cookiecutter.project_slug}}_mariadb_services}"
MARIADB_PORT="${MARIADB_PORT:-3306}"
MARIADB_USER="${MARIADB_USER:-root}"
MARIADB_PASSWORD="${MARIADB_PASSWORD}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
BACKUP_RETENTION="${BACKUP_RETENTION:-{{cookiecutter._backup_retention}}}"

# Generar nombre de archivo con timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/mariadb_backup_${TIMESTAMP}.sql.gz"

echo "=============================================="
echo "🗄️  MariaDB Backup - $(date)"
echo "=============================================="
echo "📍 Host: ${MARIADB_HOST}:${MARIADB_PORT}"
echo "👤 User: ${MARIADB_USER}"
echo "📁 Output: ${BACKUP_FILE}"
echo "🔄 Retention: ${BACKUP_RETENTION} days"
echo "=============================================="

# Ejecutar backup con mariadb-dump
# Docs: https://mariadb.com/kb/en/mariadb-dump/
echo "⏳ Starting backup..."

mariadb-dump \
    --host="${MARIADB_HOST}" \
    --port="${MARIADB_PORT}" \
    --user="${MARIADB_USER}" \
    --password="${MARIADB_PASSWORD}" \
    --all-databases \
    --single-transaction \
    --quick \
    --routines \
    --triggers \
    --events \
    --add-drop-database \
    --add-drop-table \
    --add-drop-trigger \
    --flush-privileges \
    --hex-blob \
    --default-character-set=utf8mb4 \
    | gzip > "${BACKUP_FILE}"

# Verificar que el backup se creó correctamente
if [ -f "${BACKUP_FILE}" ] && [ -s "${BACKUP_FILE}" ]; then
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo "✅ Backup completed successfully!"
    echo "📦 Size: ${BACKUP_SIZE}"
else
    echo "❌ Backup failed! File not created or empty."
    exit 1
fi

# Limpiar backups antiguos
echo ""
echo "🧹 Cleaning old backups (older than ${BACKUP_RETENTION} days)..."
DELETED_COUNT=$(find "${BACKUP_DIR}" -name "mariadb_backup_*.sql.gz" -type f -mtime +${BACKUP_RETENTION} -delete -print | wc -l)
echo "🗑️  Deleted ${DELETED_COUNT} old backup(s)"

# Listar backups actuales
echo ""
echo "📋 Current backups:"
ls -lh "${BACKUP_DIR}"/mariadb_backup_*.sql.gz 2>/dev/null || echo "   No backups found"

echo ""
echo "=============================================="
echo "✅ Backup process completed!"
echo "=============================================="
