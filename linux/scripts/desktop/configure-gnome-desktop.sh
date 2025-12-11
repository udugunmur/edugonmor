#!/bin/bash
#
# configure-gnome-desktop.sh - GNOME desktop configuration for development
#
# This script applies GNOME settings optimized for development workstations:
# - Disables automatic suspend and screensaver
# - Shows hidden files in file manager
# - Increases terminal history
# - Optimizes keyboard repeat speed
# - Disables telemetry
#
# Run as normal user (NOT root)
#
# Usage: ./configure-gnome-desktop.sh
#
# Documentation:
#   - gsettings: https://wiki.gnome.org/Projects/dconf
#   - GNOME settings: https://help.gnome.org/admin/system-admin-guide/stable/
#

set -e

# =============================================================================
# FUNCTIONS
# =============================================================================

check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "[ERROR] No ejecutar como root. Usa tu usuario normal."
        exit 1
    fi
}

check_gsettings() {
    if ! command -v gsettings &> /dev/null; then
        echo "[WARN] gsettings no encontrado. ¿Estás en GNOME?"
        exit 0
    fi
}

configure_power() {
    echo "[PASO] Configurando energía..."
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
    echo "[OK] Suspensión automática deshabilitada"
}

configure_display() {
    echo "[PASO] Configurando pantalla..."
    gsettings set org.gnome.desktop.session idle-delay 0
    echo "[OK] Apagado de pantalla deshabilitado"
}

configure_screensaver() {
    echo "[PASO] Configurando screensaver..."
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
    echo "[OK] Screensaver deshabilitado"
}

configure_nautilus() {
    echo "[PASO] Configurando Nautilus..."
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
    echo "[OK] Archivos ocultos visibles en Nautilus"
}

configure_terminal() {
    echo "[PASO] Configurando Terminal..."
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ scrollback-lines 100000 2>/dev/null || true
    echo "[OK] Historial de terminal aumentado"
}

configure_keyboard() {
    echo "[PASO] Configurando teclado..."
    gsettings set org.gnome.desktop.peripherals.keyboard delay 200
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 20
    echo "[OK] Velocidad de teclado optimizada"
}

configure_privacy() {
    echo "[PASO] Configurando privacidad..."
    gsettings set org.gnome.desktop.privacy report-technical-problems false
    gsettings set org.gnome.desktop.privacy send-software-usage-stats false
    echo "[OK] Telemetría deshabilitada"
}

print_header() {
    echo "=========================================="
    echo "  Configuración de GNOME Desktop"
    echo "=========================================="
    echo ""
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    print_header
    check_not_root
    check_gsettings
    
    echo "Aplicando configuración de GNOME..."
    echo ""
    
    configure_power
    configure_display
    configure_screensaver
    configure_nautilus
    configure_terminal
    configure_keyboard
    configure_privacy
    
    echo ""
    echo "[DONE] Configuración de GNOME aplicada"
}

main "$@"
