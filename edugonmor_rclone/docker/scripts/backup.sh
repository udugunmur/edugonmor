#!/bin/bash
set -e

echo "----------------------------------------------------------------"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iniciando proceso de backup..."
echo "Origen: $BACKUP_SOURCE"
echo "Destino: $BACKUP_DEST"

# Verificaciones previas
if [ ! -f "$RCLONE_CONFIG" ]; then
    echo "[ERROR] No se encontró el archivo de configuración de Rclone en: $RCLONE_CONFIG"
    echo "Asegúrate de montar el archivo rclone.conf correctamente."
    exit 1
fi

# Verificar si el origen es local antes de comprobar si está vacío
if [[ "$BACKUP_SOURCE" != *":"* ]]; then
    if [ -d "$BACKUP_SOURCE" ] && [ -z "$(ls -A $BACKUP_SOURCE)" ]; then
       echo "[WARNING] El directorio de origen local $BACKUP_SOURCE parece estar vacío."
    elif [ ! -d "$BACKUP_SOURCE" ]; then
       echo "[WARNING] El origen $BACKUP_SOURCE no es un directorio local existente (o es un remoto)."
    fi
else
    echo "[INFO] El origen es remoto ($BACKUP_SOURCE), saltando verificación de directorio local vacío."
fi

# Variables por defecto
RCLONE_CMD=${RCLONE_CMD:-sync}

# Ejecución de Rclone
# Usamos la variable RCLONE_CMD (por defecto 'sync') para flexibilidad (sync/copy).
# --config: Ruta explícita al archivo de configuración.
# --create-empty-src-dirs: Para replicar estructura exacta.
# -v: Verbose para logs.
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ejecutando rclone $RCLONE_CMD..."

rclone "$RCLONE_CMD" "$BACKUP_SOURCE" "$BACKUP_DEST" \
    --config "$RCLONE_CONFIG" \
    --create-empty-src-dirs \
    -v \
    --stats 1m

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completado EXITOSAMENTE."
    
    # Opcional: Llamada a Healthcheck URL si se configura
    if [ -n "$CHECK_URL" ]; then
        echo "Notificando éxito a $CHECK_URL"
        wget -q -O /dev/null "$CHECK_URL"
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] El backup falló con código de salida $EXIT_CODE."
    exit $EXIT_CODE
fi
echo "----------------------------------------------------------------"
