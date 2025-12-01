#!/bin/bash
#
# gnome-settings.sh - Configuración de GNOME para desarrollo
#
# Ejecutar como usuario normal (NO root)
#
# Uso: ./gnome-settings.sh
#

# Verificar que no se ejecute como root
if [ "$EUID" -eq 0 ]; then
    echo "[ERROR] No ejecutar como root. Usa tu usuario normal."
    exit 1
fi

echo "Aplicando configuración de GNOME..."

# Verificar que gsettings está disponible
if ! command -v gsettings &> /dev/null; then
    echo "[WARN] gsettings no encontrado. ¿Estás en GNOME?"
    exit 0
fi

# Energía - Nunca suspender
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
echo "[OK] Suspensión automática deshabilitada"

# Pantalla - No apagar
gsettings set org.gnome.desktop.session idle-delay 0
echo "[OK] Apagado de pantalla deshabilitado"

# Screensaver - Deshabilitar
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
echo "[OK] Screensaver deshabilitado"

# Nautilus - Mostrar archivos ocultos
gsettings set org.gnome.nautilus.preferences show-hidden-files true
echo "[OK] Archivos ocultos visibles en Nautilus"

# Terminal - Tamaño de historial
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ scrollback-lines 100000 2>/dev/null || true
echo "[OK] Historial de terminal aumentado"

# Teclado - Velocidad de repetición
gsettings set org.gnome.desktop.peripherals.keyboard delay 200
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 20
echo "[OK] Velocidad de teclado optimizada"

# Privacidad - No enviar informes
gsettings set org.gnome.desktop.privacy report-technical-problems false
gsettings set org.gnome.desktop.privacy send-software-usage-stats false
echo "[OK] Telemetría deshabilitada"

echo ""
echo "[DONE] Configuración de GNOME aplicada"
