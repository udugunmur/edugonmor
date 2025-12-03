#!/bin/bash
#
# backup-onedrive.sh - Manual backup from OneDrive to local disk
#
# This script downloads all OneDrive content to local disk
# using rclone copy (does not delete files at destination).
#
# Usage: ./backup-onedrive.sh
#
# Documentation: https://rclone.org/commands/rclone_copy/
#

# =============================================================================
# CONFIGURATION
# =============================================================================
REMOTE_NAME="onedrive-edugonmor"
REMOTE_PATH=""
DEST_DIR="/mnt/disk2/rclone/oneDrive/edugonmor"
LOG_DIR="/var/log/rclone"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/onedrive-backup-${TIMESTAMP}.log"

# =============================================================================
# COLORS
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# =============================================================================
# FUNCTIONS
# =============================================================================
print_header() {
    echo ""
    echo -e "${BLUE}+======================================================================+${NC}"
    echo -e "${BLUE}|${NC}${BOLD}           BACKUP ONEDRIVE -> DISCO LOCAL                            ${NC}${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}           $(date '+%Y-%m-%d %H:%M:%S')                                      ${BLUE}|${NC}"
    echo -e "${BLUE}+======================================================================+${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
}

print_ok() {
    echo -e "  ${GREEN}[OK]${NC} $1"
}

print_info() {
    echo -e "  ${BLUE}[INFO]${NC} $1"
}

print_warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "  ${RED}[ERROR]${NC} $1"
}

print_config_line() {
    printf "  ${MAGENTA}%-20s${NC} : %s\n" "$1" "$2"
}

format_bytes() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GiB"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MiB"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc) KiB"
    else
        echo "$bytes B"
    fi
}

check_requirements() {
    print_section "PASO 1: VERIFICACION DE REQUISITOS"
    
    # Check rclone installed
    if ! command -v rclone &> /dev/null; then
        print_error "rclone no esta instalado."
        echo "         Ejecuta: make rclone"
        exit 1
    fi
    RCLONE_VERSION=$(rclone version | head -1)
    print_ok "rclone instalado: ${RCLONE_VERSION}"
    
    # Check remote exists
    if ! rclone listremotes | grep -q "^${REMOTE_NAME}:"; then
        print_error "Remote '${REMOTE_NAME}' no encontrado."
        echo "         Remotes disponibles:"
        rclone listremotes | sed 's/^/           /'
        exit 1
    fi
    print_ok "Remote '${REMOTE_NAME}' configurado"
    
    # Check OneDrive connectivity
    print_info "Verificando conexion con OneDrive..."
    if rclone lsd "${REMOTE_NAME}:" --max-depth 1 &>/dev/null; then
        print_ok "Conexion con OneDrive establecida"
    else
        print_error "No se puede conectar con OneDrive"
        exit 1
    fi
    
    # Create directories
    mkdir -p "${DEST_DIR}"
    sudo mkdir -p "${LOG_DIR}" 2>/dev/null || true
    sudo chown -R $(whoami):$(whoami) "${LOG_DIR}" 2>/dev/null || true
    print_ok "Directorios de destino y logs verificados"
}

analyze_source() {
    print_section "PASO 2: ANALISIS DEL ORIGEN (OneDrive)"
    
    print_info "Calculando tamano total en OneDrive (puede tardar)..."
    REMOTE_SIZE_OUTPUT=$(rclone size "${REMOTE_NAME}:" --exclude="Almacen personal/**" --exclude="Almacén personal/**" --json 2>/dev/null || echo '{"count":0,"bytes":0}')
    REMOTE_FILES=$(echo $REMOTE_SIZE_OUTPUT | grep -oP '"count":\K[0-9]+' 2>/dev/null || echo "?")
    REMOTE_BYTES=$(echo $REMOTE_SIZE_OUTPUT | grep -oP '"bytes":\K[0-9]+' 2>/dev/null || echo "0")
    
    if [ "$REMOTE_BYTES" != "0" ]; then
        REMOTE_SIZE_HUMAN=$(format_bytes $REMOTE_BYTES)
    else
        REMOTE_SIZE_HUMAN="No disponible"
    fi
    
    print_ok "Archivos en OneDrive: ${BOLD}${REMOTE_FILES}${NC} archivos"
    print_ok "Tamano total: ${BOLD}${REMOTE_SIZE_HUMAN}${NC}"
    
    # List main folders
    print_info "Carpetas principales en OneDrive:"
    rclone lsd "${REMOTE_NAME}:" --max-depth 1 2>/dev/null | awk '{print "         - " $NF}' | head -10
}

analyze_destination() {
    print_section "PASO 3: ANALISIS DEL DESTINO (Disco Local)"
    
    if [ -d "${DEST_DIR}" ] && [ "$(ls -A ${DEST_DIR} 2>/dev/null)" ]; then
        LOCAL_SIZE=$(du -sh "${DEST_DIR}" 2>/dev/null | cut -f1)
        LOCAL_FILES=$(find "${DEST_DIR}" -type f 2>/dev/null | wc -l)
        print_ok "Backup existente encontrado"
        print_ok "Archivos locales: ${BOLD}${LOCAL_FILES}${NC} archivos"
        print_ok "Tamano local: ${BOLD}${LOCAL_SIZE}${NC}"
    else
        print_info "Directorio destino vacio (primer backup)"
        LOCAL_FILES=0
    fi
    
    # Disk space
    DISK_AVAIL=$(df -h "${DEST_DIR}" | tail -1 | awk '{print $4}')
    DISK_USED_PCT=$(df -h "${DEST_DIR}" | tail -1 | awk '{print $5}')
    print_ok "Espacio disponible en disco: ${BOLD}${DISK_AVAIL}${NC} (${DISK_USED_PCT} usado)"
}

show_configuration() {
    print_section "PASO 4: CONFIGURACION DEL BACKUP"
    
    print_config_line "Remote" "${REMOTE_NAME}:"
    print_config_line "Destino" "${DEST_DIR}"
    print_config_line "Archivo de log" "${LOG_FILE}"
    print_config_line "Metodo" "rclone copy (no borra archivos)"
    print_config_line "Exclusiones" "Almacen personal (Personal Vault)"
    print_config_line "Transferencias" "4 paralelas"
    print_config_line "Checkers" "8 paralelos"
    print_config_line "Stats" "Cada 5 segundos"
}

execute_backup() {
    print_section "PASO 5: EJECUCION DEL BACKUP"
    
    START_TIME=$(date +%s)
    print_info "Hora de inicio: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo -e "${YELLOW}  Progreso del backup:${NC}"
    echo -e "${YELLOW}  --------------------------------------------------------------------${NC}"
    echo ""
    
    # Execute rclone copy with detailed progress
    rclone copy "${REMOTE_NAME}:${REMOTE_PATH}" "${DEST_DIR}" \
        --exclude="Almacén personal/**" \
        --exclude="Almacen personal/**" \
        --progress \
        --stats=5s \
        --stats-one-line-date \
        --transfers=4 \
        --checkers=8 \
        --log-file="${LOG_FILE}" \
        --log-level=INFO \
        --stats-file-name-length=40 \
        --ignore-errors || true
    
    RCLONE_EXIT_CODE=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    # Format duration
    DURATION_HOURS=$((DURATION / 3600))
    DURATION_MIN=$(((DURATION % 3600) / 60))
    DURATION_SEC=$((DURATION % 60))
    DURATION_HUMAN="${DURATION_HOURS}h ${DURATION_MIN}m ${DURATION_SEC}s"
    
    echo ""
    echo -e "${YELLOW}  --------------------------------------------------------------------${NC}"
}

print_summary() {
    print_section "PASO 6: RESUMEN FINAL"
    
    if [ ${RCLONE_EXIT_CODE} -eq 0 ]; then
        echo ""
        echo -e "${GREEN}  +================================================================+${NC}"
        echo -e "${GREEN}  |              BACKUP COMPLETADO EXITOSAMENTE                   |${NC}"
        echo -e "${GREEN}  +================================================================+${NC}"
    else
        echo ""
        echo -e "${YELLOW}  +================================================================+${NC}"
        echo -e "${YELLOW}  |           BACKUP COMPLETADO CON ADVERTENCIAS                  |${NC}"
        echo -e "${YELLOW}  +================================================================+${NC}"
    fi
    
    echo ""
    
    # Final statistics
    NEW_LOCAL_SIZE=$(du -sh "${DEST_DIR}" 2>/dev/null | cut -f1)
    NEW_LOCAL_FILES=$(find "${DEST_DIR}" -type f 2>/dev/null | wc -l)
    
    print_config_line "Hora de inicio" "$(date -d @${START_TIME} '+%Y-%m-%d %H:%M:%S')"
    print_config_line "Hora de fin" "$(date -d @${END_TIME} '+%Y-%m-%d %H:%M:%S')"
    print_config_line "Duracion total" "${DURATION_HUMAN}"
    echo ""
    print_config_line "Archivos en destino" "${NEW_LOCAL_FILES} archivos"
    print_config_line "Tamano en destino" "${NEW_LOCAL_SIZE}"
    print_config_line "Log guardado en" "${LOG_FILE}"
    
    # Show errors if any
    if [ -f "${LOG_FILE}" ]; then
        ERROR_COUNT=$(grep -c "ERROR" "${LOG_FILE}" 2>/dev/null | head -1 || echo "0")
        ERROR_COUNT=${ERROR_COUNT:-0}
        WARN_COUNT=$(grep -c "WARN" "${LOG_FILE}" 2>/dev/null | head -1 || echo "0")
        WARN_COUNT=${WARN_COUNT:-0}
        
        echo ""
        if [ "${ERROR_COUNT}" -gt 0 ] 2>/dev/null; then
            print_warn "Errores encontrados: ${ERROR_COUNT} (ver log para detalles)"
        fi
        if [ "${WARN_COUNT}" -gt 0 ] 2>/dev/null; then
            print_warn "Advertencias: ${WARN_COUNT}"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}----------------------------------------------------------------------${NC}"
    echo -e "  ${CYAN}Comandos utiles:${NC}"
    echo -e "    Ver log completo:    ${BOLD}cat ${LOG_FILE}${NC}"
    echo -e "    Ver errores:         ${BOLD}grep ERROR ${LOG_FILE}${NC}"
    echo -e "    Espacio en disco:    ${BOLD}df -h ${DEST_DIR}${NC}"
    echo -e "    Listar archivos:     ${BOLD}ls -la ${DEST_DIR}${NC}"
    echo -e "${BLUE}----------------------------------------------------------------------${NC}"
    echo ""
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

main() {
    print_header
    check_requirements
    analyze_source
    analyze_destination
    show_configuration
    execute_backup
    print_summary
}

main "$@"

exit 0
