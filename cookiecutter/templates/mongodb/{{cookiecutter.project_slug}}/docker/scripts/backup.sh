#!/bin/bash
# ============================================================================
# Script de Backup MongoDB - Herramienta Oficial mongodump
# ============================================================================
# Documentación: https://www.mongodb.com/docs/database-tools/mongodump/

set -e

# Configuración desde variables de entorno
MONGO_HOST="${MONGO_HOST:-localhost}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_USER="${MONGO_USER:-root}"
MONGO_PASSWORD="${MONGO_PASSWORD}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
BACKUP_RETENTION="${BACKUP_RETENTION:-10}"

# Timestamp para el nombre del archivo
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

echo "============================================"
echo "MongoDB Backup - $(date)"
echo "============================================"
echo "Host: ${MONGO_HOST}:${MONGO_PORT}"
echo "Backup Path: ${BACKUP_PATH}"
echo "Retention: ${BACKUP_RETENTION} days"
echo "============================================"

# Ejecutar mongodump (herramienta oficial de MongoDB)
echo "[INFO] Iniciando backup con mongodump..."
mongodump \
    --host="${MONGO_HOST}" \
    --port="${MONGO_PORT}" \
    --username="${MONGO_USER}" \
    --password="${MONGO_PASSWORD}" \
    --authenticationDatabase=admin \
    --archive="${BACKUP_PATH}.gz" \
    --gzip

if [ $? -eq 0 ]; then
    echo "[OK] Backup completado: ${BACKUP_PATH}.gz"
    
    # Mostrar tamaño del backup
    BACKUP_SIZE=$(du -h "${BACKUP_PATH}.gz" | cut -f1)
    echo "[INFO] Tamaño del backup: ${BACKUP_SIZE}"
else
    echo "[ERROR] Fallo en el backup"
    exit 1
fi

# Limpiar backups antiguos
echo "[INFO] Limpiando backups con más de ${BACKUP_RETENTION} días..."
find "${BACKUP_DIR}" -name "mongodb_backup_*.gz" -type f -mtime +${BACKUP_RETENTION} -delete

# Contar backups restantes
BACKUP_COUNT=$(find "${BACKUP_DIR}" -name "mongodb_backup_*.gz" -type f | wc -l)
echo "[INFO] Backups disponibles: ${BACKUP_COUNT}"

echo "============================================"
echo "Backup finalizado: $(date)"
echo "============================================"
