#!/bin/bash
#
# configure-power-management.sh - Configure power management and suspend settings
#
# This script disables system suspend, hibernate and configures power-related
# settings including CPU performance governor.
#
# Usage: sudo ./configure-power-management.sh [--disable-suspend] [--cpu-performance] [--all]
#
# Options:
#   --disable-suspend    Only disable suspend/hibernate targets
#   --cpu-performance    Only configure CPU performance governor
#   --all                Apply all power management settings (default)
#
# Documentation:
#   - systemd targets: https://www.freedesktop.org/software/systemd/man/systemd.special.html
#   - CPU governor: https://www.kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../config"
SERVICE_FILE="/etc/systemd/system/cpu-performance.service"

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
    echo "  Configuración de Gestión de Energía"
    echo "=========================================="
    echo ""
}

disable_suspend() {
    echo "[PASO] Deshabilitando suspensión e hibernación..."
    
    # Mask all sleep targets
    systemctl mask sleep.target
    systemctl mask suspend.target
    systemctl mask hibernate.target
    systemctl mask hybrid-sleep.target
    
    echo "[OK] Suspensión e hibernación deshabilitadas"
    echo ""
    echo "Verificación:"
    systemctl status sleep.target --no-pager 2>&1 | head -3 || true
}

configure_cpu_performance() {
    echo "[PASO] Configurando CPU en modo performance..."
    
    # Check if service file exists in config
    if [[ ! -f "$CONFIG_DIR/cpu-performance.service" ]]; then
        echo "[ERROR] Archivo de servicio no encontrado: $CONFIG_DIR/cpu-performance.service"
        exit 1
    fi
    
    # Copy service file
    cp "$CONFIG_DIR/cpu-performance.service" "$SERVICE_FILE"
    
    # Reload systemd
    systemctl daemon-reload
    
    # Enable and start service
    systemctl enable cpu-performance.service
    systemctl start cpu-performance.service
    
    echo "[OK] Servicio cpu-performance.service instalado y habilitado"
    echo ""
    echo "Governor actual:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
}

configure_sysctl() {
    echo "[PASO] Aplicando configuraciones de sysctl..."
    
    # Increase file limits
    if ! grep -q "fs.file-max" /etc/sysctl.conf 2>/dev/null; then
        echo "fs.file-max = 2097152" >> /etc/sysctl.conf
        echo "[OK] Límite de archivos aumentado (fs.file-max = 2097152)"
    else
        echo "[INFO] fs.file-max ya configurado"
    fi
    
    # Optimize swappiness
    if ! grep -q "vm.swappiness" /etc/sysctl.conf 2>/dev/null; then
        echo "vm.swappiness = 10" >> /etc/sysctl.conf
        echo "[OK] Swappiness configurado a 10"
    else
        echo "[INFO] vm.swappiness ya configurado"
    fi
    
    # Apply changes
    sysctl -p > /dev/null 2>&1
}

show_usage() {
    echo "Uso: $0 [--disable-suspend] [--cpu-performance] [--sysctl] [--all]"
    echo ""
    echo "Opciones:"
    echo "  --disable-suspend    Solo deshabilitar suspensión/hibernación"
    echo "  --cpu-performance    Solo configurar CPU en modo performance"
    echo "  --sysctl             Solo configurar parámetros sysctl"
    echo "  --all                Aplicar todas las configuraciones (por defecto)"
    echo ""
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    check_root
    print_header
    
    local do_suspend=false
    local do_cpu=false
    local do_sysctl=false
    local do_all=true
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --disable-suspend)
                do_suspend=true
                do_all=false
                shift
                ;;
            --cpu-performance)
                do_cpu=true
                do_all=false
                shift
                ;;
            --sysctl)
                do_sysctl=true
                do_all=false
                shift
                ;;
            --all)
                do_all=true
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
    
    # Apply configurations
    if [[ $do_all == true ]]; then
        disable_suspend
        echo ""
        configure_cpu_performance
        echo ""
        configure_sysctl
    else
        [[ $do_suspend == true ]] && disable_suspend
        [[ $do_cpu == true ]] && configure_cpu_performance
        [[ $do_sysctl == true ]] && configure_sysctl
    fi
    
    echo ""
    echo "=========================================="
    echo "  Configuración completada"
    echo "=========================================="
}

main "$@"
