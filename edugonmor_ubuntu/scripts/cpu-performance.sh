#!/bin/bash
#
# cpu-performance.sh - Configura CPU en modo performance
#
# Uso: sudo ./cpu-performance.sh
#

set -e

SERVICE_FILE="/etc/systemd/system/cpu-performance.service"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Configurando CPU en modo performance..."

# Copiar archivo de servicio
cp "$SCRIPT_DIR/../config/cpu-performance.service" "$SERVICE_FILE"

# Recargar systemd
systemctl daemon-reload

# Habilitar e iniciar servicio
systemctl enable cpu-performance.service
systemctl start cpu-performance.service

echo "[OK] Servicio cpu-performance.service instalado y habilitado"
echo ""
echo "Governor actual:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
