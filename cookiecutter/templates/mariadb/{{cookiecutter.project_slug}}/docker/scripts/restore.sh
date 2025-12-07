#!/bin/bash
# ============================================================================
# MariaDB {{cookiecutter.mariadb_version}} - Restore Script
# ============================================================================
# Documentación: https://mariadb.com/docs/server/server-usage/backup-and-restore/backup-and-restore-overview/#mariadb-dump
# Uso: ./restore.sh [backup_file.sql.gz]
# ============================================================================

set -e

# Variables de entorno (inyectadas desde docker-compose)
MARIADB_HOST="${MARIADB_HOST:-{{cookiecutter.project_slug}}_mariadb_services}"
MARIADB_PORT="${MARIADB_PORT:-3306}"
MARIADB_USER="${MARIADB_USER:-root}"
MARIADB_PASSWORD="${MARIADB_PASSWORD}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"

echo "=============================================="
echo "🗄️  MariaDB Restore - $(date)"
echo "=============================================="

# Determinar archivo de backup a restaurar
if [ -n "$1" ]; then
    # Si se proporciona un argumento, usar ese archivo
    if [[ "$1" == /* ]]; then
        BACKUP_FILE="$1"
    else
        BACKUP_FILE="${BACKUP_DIR}/$1"
    fi
else
    # Si no se proporciona, usar el backup más reciente
    BACKUP_FILE=$(ls -t "${BACKUP_DIR}"/mariadb_backup_*.sql.gz 2>/dev/null | head -n 1)
    
    if [ -z "${BACKUP_FILE}" ]; then
        echo "❌ No backup files found in ${BACKUP_DIR}"
        echo ""
        echo "Usage: $0 [backup_file.sql.gz]"
        exit 1
    fi
fi

# Verificar que el archivo existe
if [ ! -f "${BACKUP_FILE}" ]; then
    echo "❌ Backup file not found: ${BACKUP_FILE}"
    exit 1
fi

BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)

echo "📍 Host: ${MARIADB_HOST}:${MARIADB_PORT}"
echo "👤 User: ${MARIADB_USER}"
echo "📁 Backup file: ${BACKUP_FILE}"
echo "📦 Size: ${BACKUP_SIZE}"
echo "=============================================="
echo ""
echo "⚠️  WARNING: This will OVERWRITE existing databases!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
    echo "❌ Restore cancelled."
    exit 0
fi

echo ""
echo "⏳ Starting restore..."

# Restaurar usando gunzip y mariadb client
gunzip -c "${BACKUP_FILE}" | mariadb \
    --host="${MARIADB_HOST}" \
    --port="${MARIADB_PORT}" \
    --user="${MARIADB_USER}" \
    --password="${MARIADB_PASSWORD}"

echo ""
echo "=============================================="
echo "✅ Restore completed successfully!"
echo "=============================================="
