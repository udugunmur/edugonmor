#!/bin/bash
set -e

# Validar argumentos
if [ -z "$1" ]; then
    echo "Uso: restore.sh <archivo_backup.sql.gz>"
    echo "Archivos disponibles en /backups:"
    ls -lh /backups/*.sql.gz 2>/dev/null || echo "No hay backups disponibles."
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
    # Intentar buscar en el directorio de backups si solo se pasa el nombre
    if [ -f "/backups/${BACKUP_FILE}" ]; then
        BACKUP_FILE="/backups/${BACKUP_FILE}"
    else
        echo "Error: El archivo ${BACKUP_FILE} no existe."
        exit 1
    fi
fi

echo "[$(date)] Iniciando restauración desde ${BACKUP_FILE}..."

# Advertencia de seguridad
echo "⚠️  ADVERTENCIA: Esto borrará y sobrescribirá los datos actuales."
echo "Esperando 5 segundos antes de continuar..."
sleep 5

export MYSQL_PWD="${MYSQL_PASSWORD}"

# Restaurar
gunzip < "${BACKUP_FILE}" | mysql \
    -h "${MYSQL_HOST}" \
    -u "${MYSQL_USER}"

echo "[$(date)] Restauración completada."
