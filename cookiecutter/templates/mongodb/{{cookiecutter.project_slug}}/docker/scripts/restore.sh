#!/bin/bash
# ============================================================================
# Script de Restore MongoDB - Herramienta Oficial mongorestore
# ============================================================================
# Documentación: https://www.mongodb.com/docs/database-tools/mongorestore/

set -e

# Configuración desde variables de entorno
MONGO_HOST="${MONGO_HOST:-localhost}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_USER="${MONGO_USER:-root}"
MONGO_PASSWORD="${MONGO_PASSWORD}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"

# Verificar que se proporcionó un archivo de backup
if [ -z "$1" ]; then
    echo "============================================"
    echo "MongoDB Restore - Uso"
    echo "============================================"
    echo "Uso: $0 <archivo_backup.gz>"
    echo ""
    echo "Backups disponibles:"
    ls -lh "${BACKUP_DIR}"/mongodb_backup_*.gz 2>/dev/null || echo "  (ninguno encontrado)"
    echo "============================================"
    exit 1
fi

BACKUP_FILE="$1"

# Si no es ruta absoluta, buscar en BACKUP_DIR
if [[ ! "$BACKUP_FILE" = /* ]]; then
    BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE}"
fi

# Verificar que el archivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "[ERROR] Archivo de backup no encontrado: ${BACKUP_FILE}"
    exit 1
fi

echo "============================================"
echo "MongoDB Restore - $(date)"
echo "============================================"
echo "Host: ${MONGO_HOST}:${MONGO_PORT}"
echo "Backup File: ${BACKUP_FILE}"
echo "============================================"

# Confirmar restauración
read -p "¿Estás seguro de que deseas restaurar? Esto puede sobrescribir datos existentes. [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "[INFO] Restauración cancelada"
    exit 0
fi

# Ejecutar mongorestore (herramienta oficial de MongoDB)
echo "[INFO] Iniciando restauración con mongorestore..."
mongorestore \
    --host="${MONGO_HOST}" \
    --port="${MONGO_PORT}" \
    --username="${MONGO_USER}" \
    --password="${MONGO_PASSWORD}" \
    --authenticationDatabase=admin \
    --archive="${BACKUP_FILE}" \
    --gzip \
    --drop

if [ $? -eq 0 ]; then
    echo "[OK] Restauración completada exitosamente"
else
    echo "[ERROR] Fallo en la restauración"
    exit 1
fi

echo "============================================"
echo "Restore finalizado: $(date)"
echo "============================================"
