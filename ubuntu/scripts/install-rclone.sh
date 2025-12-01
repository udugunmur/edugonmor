#!/bin/bash
#
# install-rclone.sh - Instalación de Rclone en Ubuntu
#
# Uso: sudo ./install-rclone.sh
#
# Descripción:
#   - Instala rclone desde el script oficial
#   - Instala fuse3 para montaje de sistemas de archivos
#   - Crea directorios de configuración y montaje
#

set -e

echo "=========================================="
echo "  Instalación de Rclone"
echo "=========================================="
echo ""

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script requiere permisos de root"
    echo "Uso: sudo ./install-rclone.sh"
    exit 1
fi

# Usuario real (no root)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

echo "[INFO] Usuario: $REAL_USER"
echo "[INFO] Home: $REAL_HOME"
echo ""

# Paso 1: Instalar dependencias
echo "[PASO 1] Instalando dependencias (fuse3, unzip, curl)..."
apt-get update -qq
apt-get install -y fuse3 unzip curl
echo "[OK] Dependencias instaladas"
echo ""

# Paso 2: Instalar rclone
echo "[PASO 2] Instalando rclone desde script oficial..."
if command -v rclone &> /dev/null; then
    CURRENT_VERSION=$(rclone version --check | head -1 || rclone version | head -1)
    echo "[INFO] Rclone ya instalado: $CURRENT_VERSION"
    echo "[INFO] Actualizando a última versión..."
fi

curl -s https://rclone.org/install.sh | bash
echo "[OK] Rclone instalado"
echo ""

# Paso 3: Crear directorios de configuración
echo "[PASO 3] Creando directorios de configuración..."
RCLONE_CONFIG_DIR="$REAL_HOME/.config/rclone"
mkdir -p "$RCLONE_CONFIG_DIR"
chown -R "$REAL_USER:$REAL_USER" "$RCLONE_CONFIG_DIR"
chmod 700 "$RCLONE_CONFIG_DIR"
echo "[OK] Directorio de configuración: $RCLONE_CONFIG_DIR"
echo ""

# Paso 4: Crear directorios de montaje
echo "[PASO 4] Creando directorios de montaje..."
MOUNT_BASE="/mnt/disk2/rclone"
mkdir -p "$MOUNT_BASE/gdrive"
mkdir -p "$MOUNT_BASE/onedrive"
chown -R "$REAL_USER:$REAL_USER" "$MOUNT_BASE"
echo "[OK] Directorios de montaje creados:"
echo "     - $MOUNT_BASE/gdrive"
echo "     - $MOUNT_BASE/onedrive"
echo ""

# Paso 5: Configurar fuse para permitir montajes por usuario
echo "[PASO 5] Configurando FUSE..."
if grep -q "^user_allow_other" /etc/fuse.conf 2>/dev/null; then
    echo "[INFO] FUSE ya configurado para user_allow_other"
else
    echo "user_allow_other" >> /etc/fuse.conf
    echo "[OK] FUSE configurado para permitir montajes de usuario"
fi
echo ""

# Paso 6: Verificar instalación
echo "[PASO 6] Verificando instalación..."
RCLONE_VERSION=$(rclone version | head -1)
echo "[OK] $RCLONE_VERSION"
echo ""

echo "=========================================="
echo "  Instalación completada"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "  1. Ejecuta './scripts/configure-rclone.sh' para configurar remotos"
echo "  2. O configura manualmente con 'rclone config'"
echo ""
echo "Documentación: docs/RCLONE.md"
