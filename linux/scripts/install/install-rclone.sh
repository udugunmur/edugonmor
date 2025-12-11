#!/bin/bash
#
# install-rclone.sh - Install rclone using the official installation script
#
# This script installs rclone for file synchronization with cloud services.
# Method: Official installation script (https://rclone.org/install/)
#
# Usage: sudo ./install-rclone.sh
#

set -e

# Check root permissions
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Este script debe ejecutarse como root (sudo)."
        exit 1
    fi
}

print_header() {
    echo "=== Instalación de rclone ==="
    echo ""
}

check_existing_installation() {
    if command -v rclone &> /dev/null; then
        CURRENT_VERSION=$(rclone version | head -n 1)
        echo "[INFO] rclone ya está instalado: $CURRENT_VERSION"
        echo "[INFO] Procediendo a actualizar a la última versión..."
    else
        echo "[INFO] rclone no está instalado. Procediendo con la instalación..."
    fi
}

install_dependencies() {
    echo "[PASO 1] Verificando dependencias..."
    apt-get update -qq
    apt-get install -y curl unzip -qq
    echo "[OK] Dependencias instaladas."
}

install_rclone() {
    echo "[PASO 2] Descargando e instalando rclone desde el repositorio oficial..."
    # Source: https://rclone.org/install/#script-installation
    curl -s https://rclone.org/install.sh | bash
}

verify_installation() {
    echo ""
    echo "[PASO 3] Verificando instalación..."
    if command -v rclone &> /dev/null; then
        INSTALLED_VERSION=$(rclone version | head -n 1)
        echo "[OK] rclone instalado correctamente: $INSTALLED_VERSION"
    else
        echo "[ERROR] La instalación de rclone falló."
        exit 1
    fi
}

print_summary() {
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
}

main() {
    check_root
    print_header
    check_existing_installation
    install_dependencies
    install_rclone
    verify_installation
    print_summary
}

main "$@"
