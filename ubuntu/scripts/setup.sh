#!/bin/bash
#
# setup.sh - Configuración inicial completa del sistema Ubuntu
#
# Uso: sudo ./setup.sh
#

set -e

echo "=========================================="
echo "  ubuntu - Setup Inicial"
echo "=========================================="
echo ""

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script requiere permisos de root"
    echo "Uso: sudo ./setup.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[PASO 1] Deshabilitando suspensión e hibernación..."
"$SCRIPT_DIR/disable-suspend.sh"

echo ""
echo "[PASO 2] Configurando CPU en modo performance..."
"$SCRIPT_DIR/cpu-performance.sh"

echo ""
echo "[PASO 3] Configurando GNOME..."
# Ejecutar como usuario normal para gsettings
SUDO_USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
sudo -u "$SUDO_USER" bash "$SCRIPT_DIR/../config/gnome-settings.sh"

echo ""
echo "[PASO 4] Instalando Rclone..."
"$SCRIPT_DIR/install-rclone.sh"

echo ""
echo "=========================================="
echo "  Configuración completada"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "  1. Ejecuta './scripts/verify.sh' para verificar la configuración"
echo "  2. Ejecuta './scripts/configure-rclone.sh' para configurar remotos cloud"
echo "  3. Ejecuta 'sudo ./scripts/enable-rclone-mount.sh' para habilitar montajes"
