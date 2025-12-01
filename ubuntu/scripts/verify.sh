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

# 4. Verificar Google Chrome
echo "=== Google Chrome ==="
if command -v google-chrome &> /dev/null; then
    CHROME_VERSION=$(google-chrome --version 2>/dev/null | awk '{print $3}')
    check_ok "Google Chrome instalado: $CHROME_VERSION"
    
    # Check repository
    if [ -f /etc/apt/sources.list.d/google-chrome.list ]; then
        check_ok "Repositorio Google configurado"
    else
        check_warn "Repositorio Google no encontrado"
    fi
    
    # Check GPG key
    if [ -f /etc/apt/keyrings/google-chrome.gpg ]; then
        check_ok "Clave GPG de Google presente"
    else
        check_warn "Clave GPG de Google no encontrada"
    fi
else
    check_warn "Google Chrome no instalado (ejecuta: make chrome)"
fi
echo ""

# 5. Información del Sistema
echo "=== Información del Sistema ==="
echo "  Sistema: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Ubuntu")"
echo "  Kernel: $(uname -r)"
echo "  Uptime: $(uptime -p)"
echo "  CPU: $(nproc) cores"
echo "  RAM: $(free -h | awk '/^Mem:/ {print $2}')"
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
