#!/bin/bash
#
# enable-rclone-mount.sh - Habilita servicios de montaje Rclone
#
# Uso: sudo ./enable-rclone-mount.sh
#
# Descripción:
#   - Instala servicios systemd para GDrive y OneDrive
#   - Crea archivos de log
#   - Habilita e inicia los servicios
#

set -e

echo "=========================================="
echo "  Habilitando Servicios Rclone Mount"
echo "=========================================="
echo ""

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script requiere permisos de root"
    echo "Uso: sudo ./enable-rclone-mount.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"

# Verificar que existen los archivos de servicio
if [ ! -f "$CONFIG_DIR/rclone-gdrive.service" ] || [ ! -f "$CONFIG_DIR/rclone-onedrive.service" ]; then
    echo "[ERROR] Archivos de servicio no encontrados en $CONFIG_DIR"
    exit 1
fi

# Verificar que rclone está instalado
if ! command -v rclone &> /dev/null; then
    echo "[ERROR] Rclone no está instalado"
    echo "Ejecuta primero: sudo ./scripts/install-rclone.sh"
    exit 1
fi

# Verificar que los remotos están configurados
echo "[PASO 1] Verificando remotos configurados..."
REMOTES=$(sudo -u edugonmor rclone listremotes 2>/dev/null || echo "")

GDRIVE_OK=false
ONEDRIVE_OK=false

if echo "$REMOTES" | grep -q "gdrive-udugunmur:"; then
    echo "[OK] Remoto gdrive-udugunmur encontrado"
    GDRIVE_OK=true
else
    echo "[WARN] Remoto gdrive-udugunmur NO configurado"
fi

if echo "$REMOTES" | grep -q "onedrive-edugonmor:"; then
    echo "[OK] Remoto onedrive-edugonmor encontrado"
    ONEDRIVE_OK=true
else
    echo "[WARN] Remoto onedrive-edugonmor NO configurado"
fi
echo ""

# Crear archivos de log
echo "[PASO 2] Creando archivos de log..."
touch /var/log/rclone-gdrive.log
touch /var/log/rclone-onedrive.log
chown edugonmor:edugonmor /var/log/rclone-gdrive.log
chown edugonmor:edugonmor /var/log/rclone-onedrive.log
echo "[OK] Archivos de log creados"
echo ""

# Copiar servicios a systemd
echo "[PASO 3] Instalando servicios systemd..."
cp "$CONFIG_DIR/rclone-gdrive.service" /etc/systemd/system/
cp "$CONFIG_DIR/rclone-onedrive.service" /etc/systemd/system/
systemctl daemon-reload
echo "[OK] Servicios instalados"
echo ""

# Habilitar e iniciar servicios
echo "[PASO 4] Habilitando servicios..."

if [ "$GDRIVE_OK" = true ]; then
    systemctl enable rclone-gdrive.service
    echo "[OK] rclone-gdrive.service habilitado"
    
    echo "Iniciando rclone-gdrive.service..."
    if systemctl start rclone-gdrive.service; then
        echo "[OK] rclone-gdrive.service iniciado"
    else
        echo "[WARN] Error al iniciar rclone-gdrive.service"
        echo "       Revisa: journalctl -u rclone-gdrive.service"
    fi
else
    echo "[SKIP] rclone-gdrive.service (remoto no configurado)"
fi

if [ "$ONEDRIVE_OK" = true ]; then
    systemctl enable rclone-onedrive.service
    echo "[OK] rclone-onedrive.service habilitado"
    
    echo "Iniciando rclone-onedrive.service..."
    if systemctl start rclone-onedrive.service; then
        echo "[OK] rclone-onedrive.service iniciado"
    else
        echo "[WARN] Error al iniciar rclone-onedrive.service"
        echo "       Revisa: journalctl -u rclone-onedrive.service"
    fi
else
    echo "[SKIP] rclone-onedrive.service (remoto no configurado)"
fi
echo ""

# Verificar montajes
echo "[PASO 5] Verificando montajes..."
sleep 3

if mountpoint -q /mnt/disk2/rclone/gdrive 2>/dev/null; then
    echo "[OK] /mnt/disk2/rclone/gdrive montado"
else
    echo "[WARN] /mnt/disk2/rclone/gdrive NO montado"
fi

if mountpoint -q /mnt/disk2/rclone/onedrive 2>/dev/null; then
    echo "[OK] /mnt/disk2/rclone/onedrive montado"
else
    echo "[WARN] /mnt/disk2/rclone/onedrive NO montado"
fi
echo ""

echo "=========================================="
echo "  Configuración completada"
echo "=========================================="
echo ""
echo "Comandos útiles:"
echo "  systemctl status rclone-gdrive.service"
echo "  systemctl status rclone-onedrive.service"
echo "  journalctl -u rclone-gdrive.service -f"
echo "  journalctl -u rclone-onedrive.service -f"
echo ""
echo "Logs:"
echo "  tail -f /var/log/rclone-gdrive.log"
echo "  tail -f /var/log/rclone-onedrive.log"
