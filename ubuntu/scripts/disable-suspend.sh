#!/bin/bash
#
# disable-suspend.sh - Deshabilita suspensión e hibernación
#
# Uso: sudo ./disable-suspend.sh
#

set -e

echo "Deshabilitando suspensión e hibernación..."

# Mask all sleep targets
systemctl mask sleep.target
systemctl mask suspend.target
systemctl mask hibernate.target
systemctl mask hybrid-sleep.target

echo "[OK] Suspensión e hibernación deshabilitadas"
echo ""
echo "Verificación:"
systemctl status sleep.target --no-pager 2>&1 | head -3 || true
