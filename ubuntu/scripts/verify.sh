#!/bin/bash
#
# verify.sh - Verify Ubuntu system configuration
#
# This script checks that all configurations have been applied correctly.
#
# Usage: ./verify.sh
#

# Note: Not using set -e because ((WARNINGS++)) returns 1 when WARNINGS=0

# =============================================================================
# COLORS
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# =============================================================================
# COUNTERS
# =============================================================================
ERRORS=0
WARNINGS=0

# =============================================================================
# FUNCTIONS
# =============================================================================

check_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ERRORS=$((ERRORS + 1))
}

check_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

print_section() {
    echo ""
    echo "=== $1 ==="
}

verify_cpu_governor() {
    print_section "CPU Governor"
    
    GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    if [[ "$GOVERNOR" == "performance" ]]; then
        check_ok "CPU Governor: performance"
    else
        check_warn "CPU Governor: $GOVERNOR (esperado: performance)"
    fi
    
    # Verify service
    if systemctl is-enabled cpu-performance.service > /dev/null 2>&1; then
        check_ok "Servicio cpu-performance.service habilitado"
    else
        check_warn "Servicio cpu-performance.service no habilitado"
    fi
}

verify_suspend() {
    print_section "Suspensión/Hibernación"
    
    local targets=("sleep.target" "suspend.target" "hibernate.target")
    
    for target in "${targets[@]}"; do
        local status=$(systemctl is-enabled "$target" 2>/dev/null || echo "masked")
        if [[ "$status" == "masked" ]]; then
            check_ok "$target deshabilitado"
        else
            check_warn "$target activo"
        fi
    done
}

verify_sysctl() {
    print_section "Configuración Sysctl"
    
    SWAPPINESS=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "unknown")
    if [[ "$SWAPPINESS" =~ ^[0-9]+$ ]] && [[ "$SWAPPINESS" -le 20 ]]; then
        check_ok "vm.swappiness: $SWAPPINESS"
    else
        check_warn "vm.swappiness: $SWAPPINESS (recomendado: 10)"
    fi
    
    FILE_MAX=$(cat /proc/sys/fs/file-max 2>/dev/null || echo "0")
    if [[ "$FILE_MAX" =~ ^[0-9]+$ ]] && [[ "$FILE_MAX" -ge 1000000 ]]; then
        check_ok "fs.file-max: $FILE_MAX"
    else
        check_warn "fs.file-max: $FILE_MAX (recomendado: >1000000)"
    fi
}

verify_chrome() {
    print_section "Google Chrome"
    
    if command -v google-chrome &> /dev/null; then
        CHROME_VERSION=$(google-chrome --version 2>/dev/null | awk '{print $3}')
        check_ok "Google Chrome instalado: $CHROME_VERSION"
        
        # Check repository
        if [[ -f /etc/apt/sources.list.d/google-chrome.list ]]; then
            check_ok "Repositorio Google configurado"
        else
            check_warn "Repositorio Google no encontrado"
        fi
        
        # Check GPG key
        if [[ -f /etc/apt/keyrings/google-chrome.gpg ]]; then
            check_ok "Clave GPG de Google presente"
        else
            check_warn "Clave GPG de Google no encontrada"
        fi
    else
        check_warn "Google Chrome no instalado (ejecuta: make chrome)"
    fi
}

verify_vnc() {
    print_section "Servidor VNC"
    
    if systemctl is-enabled x11vnc.service > /dev/null 2>&1; then
        check_ok "Servicio x11vnc.service habilitado"
        
        if systemctl is-active x11vnc.service > /dev/null 2>&1; then
            check_ok "Servicio x11vnc.service activo"
        else
            check_warn "Servicio x11vnc.service no activo"
        fi
    else
        check_warn "VNC no configurado (ejecuta: make vnc)"
    fi
}

verify_rclone() {
    print_section "rclone"
    
    if command -v rclone &> /dev/null; then
        RCLONE_VERSION=$(rclone version | head -n 1)
        check_ok "rclone instalado: $RCLONE_VERSION"
        
        # Check remotes configured
        REMOTES=$(rclone listremotes 2>/dev/null | wc -l)
        if [[ "$REMOTES" -gt 0 ]]; then
            check_ok "Remotes configurados: $REMOTES"
        else
            check_warn "No hay remotes configurados (ejecuta: rclone config)"
        fi
    else
        check_warn "rclone no instalado (ejecuta: make rclone)"
    fi
}

print_system_info() {
    print_section "Información del Sistema"
    
    echo "  Sistema: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Ubuntu")"
    echo "  Kernel: $(uname -r)"
    echo "  Uptime: $(uptime -p)"
    echo "  CPU: $(nproc) cores"
    echo "  RAM: $(free -h | awk '/^Mem:/ {print $2}')"
}

print_summary() {
    echo ""
    echo "=========================================="
    if [[ $ERRORS -gt 0 ]]; then
        echo -e "  RESULTADO: ${RED}FALLIDO${NC} ($ERRORS errores, $WARNINGS advertencias)"
        exit 1
    elif [[ $WARNINGS -gt 0 ]]; then
        echo -e "  RESULTADO: ${YELLOW}PARCIAL${NC} ($WARNINGS advertencias)"
        exit 0
    else
        echo -e "  RESULTADO: ${GREEN}TODO CORRECTO${NC}"
        exit 0
    fi
    echo "=========================================="
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    echo "=========================================="
    echo "  Verificación de Configuración Ubuntu"
    echo "=========================================="
    
    verify_cpu_governor
    verify_suspend
    verify_sysctl
    verify_chrome
    verify_vnc
    verify_rclone
    print_system_info
    print_summary
}

main "$@"
