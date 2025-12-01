#!/bin/bash
#
# setup.sh - Complete initial Ubuntu system configuration
#
# This is the main orchestrator script that applies all system configurations:
# - Power management (disable suspend, CPU performance)
# - Sysctl optimizations (file limits, swappiness)
# - GNOME desktop settings
#
# Usage: sudo ./setup.sh [--minimal|--full]
#
# Options:
#   --minimal    Only apply power management settings
#   --full       Apply all optimizations (default)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# FUNCTIONS
# =============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Este script requiere permisos de root"
        echo "Uso: sudo $0"
        exit 1
    fi
}

print_header() {
    echo "=========================================="
    echo "  ubuntu - Setup Inicial"
    echo "=========================================="
    echo ""
}

show_usage() {
    echo "Uso: sudo $0 [--minimal|--full]"
    echo ""
    echo "Opciones:"
    echo "  --minimal    Solo aplicar configuración de energía"
    echo "  --full       Aplicar todas las optimizaciones (por defecto)"
    echo ""
}

run_as_user() {
    local script="$1"
    local SUDO_USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    sudo -u "$SUDO_USER" bash "$script"
}

setup_minimal() {
    echo "[PASO 1] Configurando gestión de energía (modo performance + suspensión)..."
    "$SCRIPT_DIR/system/configure-power-management.sh" --all
}

setup_gnome() {
    echo ""
    echo "[PASO 2] Configurando GNOME..."
    # Execute as normal user for gsettings
    if [[ -n "$SUDO_USER" ]]; then
        run_as_user "$SCRIPT_DIR/desktop/configure-gnome-desktop.sh"
    else
        echo "[WARN] No se pudo detectar usuario. Ejecuta gnome-settings manualmente."
    fi
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "  Configuración completada"
    echo "=========================================="
    echo ""
    echo "Próximos pasos:"
    echo "  1. Ejecuta './scripts/verify.sh' para verificar la configuración"
    echo "  2. Usa 'make chrome' para instalar Google Chrome"
    echo "  3. Usa 'make vnc' para habilitar acceso remoto VNC"
    echo "  4. Usa 'make rclone' para instalar sincronización cloud"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    local mode="full"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal)
                mode="minimal"
                shift
                ;;
            --full)
                mode="full"
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                echo "[ERROR] Opción desconocida: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    check_root
    print_header
    
    case $mode in
        minimal)
            setup_minimal
            ;;
        full)
            setup_minimal
            setup_gnome
            ;;
    esac
    
    print_summary
}

main "$@"
