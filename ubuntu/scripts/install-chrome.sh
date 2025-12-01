#!/bin/bash
#
# install-chrome.sh - Install Google Chrome via official Google APT repository
#
# Usage: sudo ./install-chrome.sh
#
# Documentation: https://www.google.com/linuxrepositories/
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check root permissions
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR] Este script requiere permisos de root${NC}"
        echo "Ejecuta: sudo $0"
        exit 1
    fi
}

# Print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Chrome is already installed
check_chrome_installed() {
    if command -v google-chrome &> /dev/null; then
        CURRENT_VERSION=$(google-chrome --version 2>/dev/null || echo "unknown")
        print_warning "Google Chrome ya está instalado: $CURRENT_VERSION"
        read -p "¿Deseas reinstalar/actualizar? (s/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            print_status "Instalación cancelada."
            exit 0
        fi
    fi
}

# Install dependencies
install_dependencies() {
    print_status "Instalando dependencias..."
    apt-get update
    apt-get install -y wget gnupg apt-transport-https ca-certificates
}

# Add Google's GPG key
add_google_gpg_key() {
    print_status "Añadiendo clave GPG de Google..."
    
    # Create keyrings directory if not exists
    mkdir -p /etc/apt/keyrings
    
    # Download and add Google's signing key
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | \
        gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
    
    # Set proper permissions
    chmod 644 /etc/apt/keyrings/google-chrome.gpg
    
    print_status "Clave GPG añadida correctamente."
}

# Add Google Chrome repository
add_chrome_repository() {
    print_status "Añadiendo repositorio oficial de Google Chrome..."
    
    # Add repository with signed-by reference
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | \
        tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
    
    print_status "Repositorio añadido correctamente."
}

# Install Google Chrome Stable
install_chrome() {
    print_status "Actualizando lista de paquetes..."
    apt-get update
    
    print_status "Instalando Google Chrome Stable..."
    apt-get install -y google-chrome-stable
    
    print_status "Google Chrome instalado correctamente."
}

# Verify installation
verify_installation() {
    print_status "Verificando instalación..."
    
    if command -v google-chrome &> /dev/null; then
        VERSION=$(google-chrome --version)
        print_status "✅ Instalación verificada: $VERSION"
        
        # Show binary location
        BINARY_PATH=$(which google-chrome)
        print_status "📍 Ubicación: $BINARY_PATH"
        
        return 0
    else
        print_error "❌ La verificación falló. Google Chrome no se encuentra en PATH."
        return 1
    fi
}

# Main function
main() {
    echo "=========================================="
    echo "  Instalación de Google Chrome (Stable)"
    echo "=========================================="
    echo ""
    echo "📚 Fuente: https://www.google.com/linuxrepositories/"
    echo ""
    
    check_root
    check_chrome_installed
    install_dependencies
    add_google_gpg_key
    add_chrome_repository
    install_chrome
    verify_installation
    
    echo ""
    echo "=========================================="
    echo "  ✅ Instalación completada"
    echo "=========================================="
    echo ""
    echo "Comandos útiles:"
    echo "  - Abrir Chrome: google-chrome"
    echo "  - Versión: google-chrome --version"
    echo "  - Actualizar: sudo apt update && sudo apt upgrade google-chrome-stable"
    echo ""
}

main "$@"
