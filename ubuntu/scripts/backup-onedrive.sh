#!/bin/bash
#
# backup-onedrive.sh - Backup manual de OneDrive a disco local
#
# Este script descarga todo el contenido de OneDrive al disco local
# usando rclone copy (no borra archivos en destino).
#
# Uso: ./backup-onedrive.sh
#
# Fuente: https://rclone.org/commands/rclone_copy/
#

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================
REMOTE_NAME="onedrive-edugonmor"
REMOTE_PATH=""
DEST_PATH="/mnt/disk2/rclone/oneDrive/edugonmor"
LOG_DIR="/var/log/rclone"
LOG_FILE="${LOG_DIR}/onedrive-backup-$(date +%Y%m%d_%H%M%S).log"
EXCLUDE_PATTERNS=(
    "Almacén personal/**"
)
TRANSFERS=4
STATS_INTERVAL="30s"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Check if rclone is installed
check_rclone() {
    if ! command -v rclone &> /dev/null; then
        echo "[ERROR] rclone no está instalado. Ejecuta: make rclone"
        exit 1
    fi
}

# Check if remote exists
check_remote() {
    if ! rclone listremotes | grep -q "^${REMOTE_NAME}:$"; then
        echo "[ERROR] Remote '${REMOTE_NAME}' no encontrado."
        echo "[INFO] Remotes disponibles:"
        rclone listremotes
        exit 1
    fi
}

# Create destination and log directories
create_directories() {
    if [ ! -d "$DEST_PATH" ]; then
        echo "[INFO] Creando directorio destino: $DEST_PATH"
        mkdir -p "$DEST_PATH"
    fi
    
    if [ ! -d "$LOG_DIR" ]; then
        echo "[INFO] Creando directorio de logs: $LOG_DIR"
        sudo mkdir -p "$LOG_DIR"
        sudo chown "$USER:$USER" "$LOG_DIR"
    fi
}

# Build exclude arguments
build_exclude_args() {
    local args=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        args+="--exclude \"${pattern}\" "
    done
    echo "$args"
}

# Show backup summary
show_summary() {
    echo ""
    echo "=== Configuración del Backup ==="
    echo "📦 Remote: ${REMOTE_NAME}:${REMOTE_PATH}"
    echo "📁 Destino: ${DEST_PATH}"
    echo "📝 Log: ${LOG_FILE}"
    echo "🚫 Exclusiones: ${EXCLUDE_PATTERNS[*]}"
    echo "⚡ Transferencias paralelas: ${TRANSFERS}"
    echo ""
}

# Run backup
run_backup() {
    echo "[PASO 1] Iniciando backup de OneDrive..."
    echo "[INFO] Hora de inicio: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    local start_time=$(date +%s)
    
    # Execute rclone copy with logging
    rclone copy "${REMOTE_NAME}:${REMOTE_PATH}" "${DEST_PATH}" \
        --exclude "Almacén personal/**" \
        --progress \
        --transfers "${TRANSFERS}" \
        --stats "${STATS_INTERVAL}" \
        --stats-one-line \
        --log-file "${LOG_FILE}" \
        --log-level INFO \
        --verbose
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local hours=$((duration / 3600))
    local minutes=$(( (duration % 3600) / 60 ))
    local seconds=$((duration % 60))
    
    echo ""
    echo "[OK] Backup completado."
    echo ""
    echo "=== Resumen del Backup ==="
    echo "⏱️  Duración: ${hours}h ${minutes}m ${seconds}s"
    echo "📁 Destino: ${DEST_PATH}"
    echo "📝 Log guardado en: ${LOG_FILE}"
    echo "📊 Tamaño descargado: $(du -sh "${DEST_PATH}" 2>/dev/null | cut -f1)"
    echo ""
}

# Main function
main() {
    echo ""
    echo "=== Backup OneDrive → Disco Local ==="
    echo ""
    
    echo "[PASO 0] Verificando requisitos..."
    check_rclone
    echo "[OK] rclone instalado: $(rclone version | head -n 1)"
    
    check_remote
    echo "[OK] Remote '${REMOTE_NAME}' encontrado."
    
    create_directories
    echo "[OK] Directorios verificados."
    
    show_summary
    
    run_backup
    
    echo "💡 Para ver el log completo: cat ${LOG_FILE}"
    echo ""
}

main "$@"
