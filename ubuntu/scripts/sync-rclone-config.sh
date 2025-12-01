#!/bin/bash
#
# sync-rclone-config.sh - Sincroniza configuración de Rclone con proyecto Docker
#
# Uso: ./sync-rclone-config.sh
#
# Descripción:
#   Copia ~/.config/rclone/rclone.conf al proyecto Docker rclone
#   para mantener sincronizada la configuración entre host y contenedores
#

set -e

echo "=========================================="
echo "  Sincronización de Configuración Rclone"
echo "=========================================="
echo ""

# Rutas
SOURCE_CONFIG="$HOME/.config/rclone/rclone.conf"
DOCKER_CONFIG="/home/edugonmor/repos/edugonmor/rclone/docker/config/rclone.conf"

# Verificar archivo fuente
if [ ! -f "$SOURCE_CONFIG" ]; then
    echo "[ERROR] Archivo de configuración no encontrado: $SOURCE_CONFIG"
    echo ""
    echo "Ejecuta primero './scripts/configure-rclone.sh' para crear la configuración"
    exit 1
fi

# Verificar directorio destino
DOCKER_CONFIG_DIR=$(dirname "$DOCKER_CONFIG")
if [ ! -d "$DOCKER_CONFIG_DIR" ]; then
    echo "[WARN] Directorio destino no existe, creándolo..."
    mkdir -p "$DOCKER_CONFIG_DIR"
fi

# Verificar si existe backup
if [ -f "$DOCKER_CONFIG" ]; then
    echo "[INFO] Archivo de configuración existente encontrado"
    
    # Comparar si son diferentes
    if cmp -s "$SOURCE_CONFIG" "$DOCKER_CONFIG"; then
        echo "[INFO] Los archivos son idénticos, nada que hacer"
        exit 0
    fi
    
    # Crear backup
    BACKUP_FILE="$DOCKER_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$DOCKER_CONFIG" "$BACKUP_FILE"
    echo "[OK] Backup creado: $BACKUP_FILE"
fi

# Copiar archivo
echo "[INFO] Copiando configuración..."
cp "$SOURCE_CONFIG" "$DOCKER_CONFIG"

# Establecer permisos restrictivos
chmod 600 "$DOCKER_CONFIG"

echo "[OK] Configuración sincronizada"
echo ""
echo "Fuente:  $SOURCE_CONFIG"
echo "Destino: $DOCKER_CONFIG"
echo ""
echo "NOTA: Recuerda reiniciar los contenedores Docker de rclone para aplicar cambios:"
echo "  cd /home/edugonmor/repos/edugonmor/rclone/docker && docker-compose up -d"
