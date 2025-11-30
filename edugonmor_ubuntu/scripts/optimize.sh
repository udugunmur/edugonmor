#!/bin/bash
#
# optimize.sh - Aplica optimizaciones de sistema Ubuntu
#
# Uso: sudo ./optimize.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Aplicando optimizaciones de sistema Ubuntu..."
echo ""

# Ejecutar cada script de configuración
echo "=== 1. Configurando CPU en modo performance ==="
"$SCRIPT_DIR/cpu-performance.sh"
echo ""

echo "=== 2. Deshabilitando suspensión ==="
"$SCRIPT_DIR/disable-suspend.sh"
echo ""

echo "=== 3. Aplicando configuración de GNOME ==="
if [ -f "$SCRIPT_DIR/../config/gnome-settings.sh" ]; then
    # GNOME settings debe ejecutarse como usuario normal
    if [ "$SUDO_USER" != "" ]; then
        su - "$SUDO_USER" -c "bash $SCRIPT_DIR/../config/gnome-settings.sh"
    else
        echo "[WARN] Ejecuta gnome-settings.sh como usuario normal"
    fi
fi
echo ""

echo "=== 4. Optimizaciones adicionales ==="

# Aumentar límites de archivos abiertos
if ! grep -q "fs.file-max" /etc/sysctl.conf 2>/dev/null; then
    echo "fs.file-max = 2097152" >> /etc/sysctl.conf
    sysctl -p > /dev/null 2>&1
    echo "[OK] Límite de archivos aumentado"
fi

# Deshabilitar IPv6 si no se usa
# echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

# Optimizar swappiness
if ! grep -q "vm.swappiness" /etc/sysctl.conf 2>/dev/null; then
    echo "vm.swappiness = 10" >> /etc/sysctl.conf
    sysctl -p > /dev/null 2>&1
    echo "[OK] Swappiness configurado a 10"
fi

echo ""
echo "=========================================="
echo "  Optimizaciones aplicadas correctamente"
echo "=========================================="
echo ""
echo "Ejecuta 'make verify' para verificar la configuración"
