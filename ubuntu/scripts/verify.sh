#!/bin/bash
#
# verify.sh - Verifica configuración del sistema Ubuntu
#
# Uso: ./verify.sh
#

echo "=========================================="
echo "  Verificación de Configuración Ubuntu"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0

# Función para verificar
check_ok() {
    echo "[OK] $1"
}

check_fail() {
    echo "[FAIL] $1"
    ((ERRORS++))
}

check_warn() {
    echo "[WARN] $1"
    ((WARNINGS++))
}

# 1. Verificar CPU Governor
echo "=== CPU Governor ==="
GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
if [ "$GOVERNOR" = "performance" ]; then
    check_ok "CPU Governor: performance"
else
    check_warn "CPU Governor: $GOVERNOR (esperado: performance)"
fi

# Verificar servicio
if systemctl is-enabled cpu-performance.service > /dev/null 2>&1; then
    check_ok "Servicio cpu-performance.service habilitado"
else
    check_warn "Servicio cpu-performance.service no habilitado"
fi
echo ""

# 2. Verificar Suspensión
echo "=== Suspensión/Hibernación ==="
SLEEP_MASKED=$(systemctl is-enabled sleep.target 2>/dev/null || echo "masked")
SUSPEND_MASKED=$(systemctl is-enabled suspend.target 2>/dev/null || echo "masked")
HIBERNATE_MASKED=$(systemctl is-enabled hibernate.target 2>/dev/null || echo "masked")

if [ "$SLEEP_MASKED" = "masked" ]; then
    check_ok "sleep.target deshabilitado"
else
    check_warn "sleep.target activo"
fi

if [ "$SUSPEND_MASKED" = "masked" ]; then
    check_ok "suspend.target deshabilitado"
else
    check_warn "suspend.target activo"
fi

if [ "$HIBERNATE_MASKED" = "masked" ]; then
    check_ok "hibernate.target deshabilitado"
else
    check_warn "hibernate.target activo"
fi
echo ""

# 3. Verificar Sysctl
echo "=== Configuración Sysctl ==="
SWAPPINESS=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "unknown")
if [ "$SWAPPINESS" -le 20 ] 2>/dev/null; then
    check_ok "vm.swappiness: $SWAPPINESS"
else
    check_warn "vm.swappiness: $SWAPPINESS (recomendado: 10)"
fi

FILE_MAX=$(cat /proc/sys/fs/file-max 2>/dev/null || echo "0")
if [ "$FILE_MAX" -ge 1000000 ] 2>/dev/null; then
    check_ok "fs.file-max: $FILE_MAX"
else
    check_warn "fs.file-max: $FILE_MAX (recomendado: >1000000)"
fi
echo ""

# 4. Información del Sistema
echo "=== Información del Sistema ==="
echo "  Sistema: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Ubuntu")"
echo "  Kernel: $(uname -r)"
echo "  Uptime: $(uptime -p)"
echo "  CPU: $(nproc) cores"
echo "  RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo ""

# 5. Rclone
echo "=== Rclone ==="
if command -v rclone &> /dev/null; then
    RCLONE_VERSION=$(rclone version | head -1)
    check_ok "Rclone instalado: $RCLONE_VERSION"
    
    # Verificar remotos
    REMOTES=$(rclone listremotes 2>/dev/null || echo "")
    if echo "$REMOTES" | grep -q "gdrive-udugunmur:"; then
        check_ok "Remoto gdrive-udugunmur configurado"
    else
        check_warn "Remoto gdrive-udugunmur NO configurado"
    fi
    
    if echo "$REMOTES" | grep -q "onedrive-edugonmor:"; then
        check_ok "Remoto onedrive-edugonmor configurado"
    else
        check_warn "Remoto onedrive-edugonmor NO configurado"
    fi
    
    # Verificar servicios de montaje
    if systemctl is-enabled rclone-gdrive.service > /dev/null 2>&1; then
        if systemctl is-active rclone-gdrive.service > /dev/null 2>&1; then
            check_ok "Servicio rclone-gdrive.service activo"
        else
            check_warn "Servicio rclone-gdrive.service habilitado pero NO activo"
        fi
    else
        check_warn "Servicio rclone-gdrive.service NO habilitado"
    fi
    
    if systemctl is-enabled rclone-onedrive.service > /dev/null 2>&1; then
        if systemctl is-active rclone-onedrive.service > /dev/null 2>&1; then
            check_ok "Servicio rclone-onedrive.service activo"
        else
            check_warn "Servicio rclone-onedrive.service habilitado pero NO activo"
        fi
    else
        check_warn "Servicio rclone-onedrive.service NO habilitado"
    fi
    
    # Verificar puntos de montaje
    if mountpoint -q /mnt/disk2/rclone/gdrive 2>/dev/null; then
        check_ok "Montaje /mnt/disk2/rclone/gdrive activo"
    else
        check_warn "Montaje /mnt/disk2/rclone/gdrive NO activo"
    fi
    
    if mountpoint -q /mnt/disk2/rclone/onedrive 2>/dev/null; then
        check_ok "Montaje /mnt/disk2/rclone/onedrive activo"
    else
        check_warn "Montaje /mnt/disk2/rclone/onedrive NO activo"
    fi
else
    check_warn "Rclone NO instalado"
fi
echo ""

# 6. Resumen
echo "=========================================="
if [ $ERRORS -gt 0 ]; then
    echo "  RESULTADO: FALLIDO ($ERRORS errores, $WARNINGS advertencias)"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "  RESULTADO: PARCIAL ($WARNINGS advertencias)"
    exit 0
else
    echo "  RESULTADO: TODO CORRECTO"
    exit 0
fi
echo "=========================================="
