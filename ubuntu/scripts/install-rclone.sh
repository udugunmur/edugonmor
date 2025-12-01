#!/bin/bash
#
# install-rclone.sh - Instala rclone usando el script oficial
#
# Este script instala rclone para sincronización de archivos con servicios cloud.
# Método: Script oficial de instalación (https://rclone.org/install/)
#
# Uso: sudo ./install-rclone.sh
#

set -e

# Verificar root
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Este script debe ejecutarse como root (sudo)."
    exit 1
fi

echo "=== Instalación de rclone ==="
echo ""

# 1. Verificar si rclone ya está instalado
if command -v rclone &> /dev/null; then
    CURRENT_VERSION=$(rclone version | head -n 1)
    echo "[INFO] rclone ya está instalado: $CURRENT_VERSION"
    echo "[INFO] Procediendo a actualizar a la última versión..."
else
    echo "[INFO] rclone no está instalado. Procediendo con la instalación..."
fi

# 2. Instalar dependencias necesarias
echo "[PASO 1] Verificando dependencias..."
apt-get update -qq
apt-get install -y curl unzip -qq
echo "[OK] Dependencias instaladas."

# 3. Descargar y ejecutar script oficial de instalación
# Fuente: https://rclone.org/install/#script-installation
echo "[PASO 2] Descargando e instalando rclone desde el repositorio oficial..."
curl -s https://rclone.org/install.sh | bash

# 4. Verificar instalación
echo ""
echo "[PASO 3] Verificando instalación..."
if command -v rclone &> /dev/null; then
    INSTALLED_VERSION=$(rclone version | head -n 1)
    echo "[OK] rclone instalado correctamente: $INSTALLED_VERSION"
else
    echo "[ERROR] La instalación de rclone falló."
    exit 1
fi

# 5. Mostrar ubicación de configuración
echo ""
echo "=== Instalación Completada ==="
echo ""
echo "📦 Versión instalada: $(rclone version | head -n 1)"
echo "📍 Ubicación del binario: $(which rclone)"
echo "⚙️  Archivo de configuración: ~/.config/rclone/rclone.conf"
echo ""
echo "🚀 Próximos pasos:"
echo "   1. Configura un remote: rclone config"
echo "   2. Lista remotes: rclone listremotes"
echo "   3. Documentación: https://rclone.org/docs/"
echo ""
echo "💡 Para actualizar rclone en el futuro: sudo rclone selfupdate"
