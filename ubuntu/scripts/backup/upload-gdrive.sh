#!/bin/bash
#
# upload-gdrive.sh - Upload local files to Google Drive (one-time)
#
# This script uploads content from local disk to Google Drive
# using rclone copy. It runs ONCE and does NOT sync continuously.
#
# Usage: ./upload-gdrive.sh [--yes|-y]
#
#   --yes, -y   Skip confirmation prompt and start upload immediately
#
# Documentation: https://rclone.org/commands/rclone_copy/
#                https://rclone.org/drive/
#

# =============================================================================
# CONFIGURATION
# =============================================================================
SOURCE_DIR="/mnt/disk2/rclone/oneDrive/edugonmor"
REMOTE_NAME="gdrive-udugunmur"
REMOTE_PATH=""
RCLONE_CONFIG="/home/edugonmor/repos/edugonmor/rclone/docker/config/rclone.conf"
SKIP_CONFIRM="false"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --yes|-y)
            SKIP_CONFIRM="true"
            ;;
    esac
done

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
    echo -e "${MAGENTA}+======================================================================+${NC}"
    echo -e "${MAGENTA}|${NC}${BOLD}           UPLOAD DISCO LOCAL -> GOOGLE DRIVE                        ${NC}${MAGENTA}|${NC}"
    echo -e "${MAGENTA}|${NC}           $(date '+%Y-%m-%d %H:%M:%S')                                      ${MAGENTA}|${NC}"
    echo -e "${MAGENTA}|${NC}           Cuenta: udugunmur@gmail.com                                ${MAGENTA}|${NC}"
    echo -e "${MAGENTA}+======================================================================+${NC}"
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
    
    # Check config file exists
    if [ ! -f "${RCLONE_CONFIG}" ]; then
        print_error "Archivo de configuracion no encontrado: ${RCLONE_CONFIG}"
        exit 1
    fi
    print_ok "Configuracion rclone encontrada"
    
    # Check remote exists
    if ! rclone listremotes --config="${RCLONE_CONFIG}" | grep -q "^${REMOTE_NAME}:"; then
        print_error "Remote '${REMOTE_NAME}' no encontrado."
        echo "         Remotes disponibles:"
        rclone listremotes --config="${RCLONE_CONFIG}" | sed 's/^/           /'
        exit 1
    fi
    print_ok "Remote '${REMOTE_NAME}' configurado"
    
    # Check Google Drive connectivity
    print_info "Verificando conexion con Google Drive..."
    if rclone lsd "${REMOTE_NAME}:" --config="${RCLONE_CONFIG}" --max-depth 1 &>/dev/null; then
        print_ok "Conexion con Google Drive establecida"
    else
        print_error "No se puede conectar con Google Drive"
        print_error "El token puede haber expirado. Ejecuta: rclone config reconnect ${REMOTE_NAME}:"
        exit 1
    fi
    
    # Check source directory
    if [ ! -d "${SOURCE_DIR}" ]; then
        print_error "Directorio de origen no encontrado: ${SOURCE_DIR}"
        exit 1
    fi
    print_ok "Directorio de origen verificado"
}

analyze_source() {
    print_section "PASO 2: ANALISIS DEL ORIGEN (Disco Local)"
    
    if [ -d "${SOURCE_DIR}" ] && [ "$(ls -A ${SOURCE_DIR} 2>/dev/null)" ]; then
        print_info "Calculando tamano del directorio local..."
        
        LOCAL_SIZE=$(du -sh "${SOURCE_DIR}" 2>/dev/null | cut -f1)
        LOCAL_FILES=$(find "${SOURCE_DIR}" -type f 2>/dev/null | wc -l)
        LOCAL_DIRS=$(find "${SOURCE_DIR}" -type d 2>/dev/null | wc -l)
        
        print_ok "Archivos a subir: ${BOLD}${LOCAL_FILES}${NC} archivos"
        print_ok "Carpetas: ${BOLD}${LOCAL_DIRS}${NC} directorios"
        print_ok "Tamano total: ${BOLD}${LOCAL_SIZE}${NC}"
        
        # List main folders
        print_info "Carpetas principales a subir:"
        ls -1d "${SOURCE_DIR}"/*/ 2>/dev/null | head -10 | while read dir; do
            dir_name=$(basename "$dir")
            dir_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            echo -e "         - ${dir_name} (${dir_size})"
        done
    else
        print_error "Directorio origen vacio o no accesible: ${SOURCE_DIR}"
        exit 1
    fi
}

check_gdrive_space() {
    print_section "PASO 3: VERIFICACION ESPACIO EN GOOGLE DRIVE"
    
    print_info "Consultando estado del almacenamiento..."
    
    GDRIVE_ABOUT=$(rclone about "${REMOTE_NAME}:" --config="${RCLONE_CONFIG}" --json 2>/dev/null)
    
    if [ -n "$GDRIVE_ABOUT" ]; then
        GDRIVE_TOTAL=$(echo "$GDRIVE_ABOUT" | grep -oP '"total":\K[0-9]+' 2>/dev/null || echo "0")
        GDRIVE_USED=$(echo "$GDRIVE_ABOUT" | grep -oP '"used":\K[0-9]+' 2>/dev/null || echo "0")
        GDRIVE_FREE=$(echo "$GDRIVE_ABOUT" | grep -oP '"free":\K[0-9]+' 2>/dev/null || echo "0")
        
        if [ "$GDRIVE_TOTAL" != "0" ]; then
            GDRIVE_TOTAL_HUMAN=$(format_bytes $GDRIVE_TOTAL)
            GDRIVE_USED_HUMAN=$(format_bytes $GDRIVE_USED)
            GDRIVE_FREE_HUMAN=$(format_bytes $GDRIVE_FREE)
            GDRIVE_USED_PCT=$(echo "scale=1; $GDRIVE_USED * 100 / $GDRIVE_TOTAL" | bc)
            
            print_ok "Almacenamiento total: ${BOLD}${GDRIVE_TOTAL_HUMAN}${NC}"
            print_ok "Espacio usado: ${BOLD}${GDRIVE_USED_HUMAN}${NC} (${GDRIVE_USED_PCT}%)"
            print_ok "Espacio libre: ${BOLD}${GDRIVE_FREE_HUMAN}${NC}"
            
            # Show visual bar
            BAR_WIDTH=40
            FILLED=$(echo "$GDRIVE_USED_PCT * $BAR_WIDTH / 100" | bc)
            EMPTY=$((BAR_WIDTH - FILLED))
            
            BAR=""
            for ((i=0; i<FILLED; i++)); do BAR+="█"; done
            for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
            
            echo ""
            echo -e "  ${CYAN}[${BAR}]${NC} ${GDRIVE_USED_PCT}% usado"
        else
            print_warn "No se pudo obtener informacion de almacenamiento"
        fi
    else
        print_warn "No se pudo consultar el espacio en Google Drive"
    fi
}

analyze_destination() {
    print_section "PASO 4: ANALISIS DEL DESTINO (Google Drive)"
    
    print_info "Listando contenido actual en la raiz de Google Drive..."
    
    GDRIVE_FILES=$(rclone size "${REMOTE_NAME}:${REMOTE_PATH}" --config="${RCLONE_CONFIG}" --json 2>/dev/null || echo '{"count":0,"bytes":0}')
    GDRIVE_COUNT=$(echo "$GDRIVE_FILES" | grep -oP '"count":\K[0-9]+' 2>/dev/null || echo "0")
    GDRIVE_BYTES=$(echo "$GDRIVE_FILES" | grep -oP '"bytes":\K[0-9]+' 2>/dev/null || echo "0")
    
    if [ "$GDRIVE_BYTES" != "0" ]; then
        GDRIVE_SIZE_HUMAN=$(format_bytes $GDRIVE_BYTES)
        print_ok "Archivos existentes en destino: ${BOLD}${GDRIVE_COUNT}${NC} archivos"
        print_ok "Tamano actual en destino: ${BOLD}${GDRIVE_SIZE_HUMAN}${NC}"
    else
        print_info "Destino vacio o sin acceso"
    fi
    
    # List main folders in GDrive
    print_info "Carpetas principales en Google Drive:"
    rclone lsd "${REMOTE_NAME}:${REMOTE_PATH}" --config="${RCLONE_CONFIG}" --max-depth 1 2>/dev/null | awk '{print "         - " $NF}' | head -10
}

show_configuration() {
    print_section "PASO 5: CONFIGURACION DE LA SUBIDA"
    
    print_config_line "Origen" "${SOURCE_DIR}"
    print_config_line "Destino" "${REMOTE_NAME}:${REMOTE_PATH} (raiz)"
    print_config_line "Cuenta Google" "udugunmur@gmail.com"
    print_config_line "Config rclone" "${RCLONE_CONFIG}"
    print_config_line "Metodo" "rclone copy (no borra archivos)"
    print_config_line "Transferencias" "4 paralelas"
    print_config_line "Checkers" "8 paralelos"
    print_config_line "Stats" "Cada segundo (tiempo real)"
    print_config_line "Progreso" "Barra de progreso + ETA"
    
    echo ""
    echo -e "  ${YELLOW}⚠️  IMPORTANTE: Este script sube archivos UNA SOLA VEZ.${NC}"
    echo -e "  ${YELLOW}    No mantiene sincronizacion continua.${NC}"
    echo -e "  ${YELLOW}    Los archivos existentes en destino NO se borran.${NC}"
}

confirm_upload() {
    print_section "PASO 6: CONFIRMACION"
    
    echo ""
    echo -e "  ${BOLD}${YELLOW}¿Deseas iniciar la subida a Google Drive?${NC}"
    echo ""
    echo -e "  ${CYAN}Origen:${NC}  ${SOURCE_DIR}"
    echo -e "  ${CYAN}Destino:${NC} ${REMOTE_NAME}: (Google Drive raiz)"
    echo ""
    
    # Check for --yes flag to skip confirmation
    if [ "$SKIP_CONFIRM" = "true" ]; then
        print_ok "Flag --yes detectado. Saltando confirmacion..."
        return
    fi
    
    read -p "  Escribe 'SI' para continuar (o cualquier otra tecla para cancelar): " CONFIRM
    
    if [ "$CONFIRM" != "SI" ] && [ "$CONFIRM" != "si" ] && [ "$CONFIRM" != "Si" ]; then
        echo ""
        print_warn "Operacion cancelada por el usuario."
        echo ""
        exit 0
    fi
    
    echo ""
    print_ok "Confirmacion recibida. Iniciando subida..."
}

execute_upload() {
    print_section "PASO 7: EJECUCION DE LA SUBIDA"
    
    START_TIME=$(date +%s)
    print_info "Hora de inicio: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo -e "${YELLOW}  Progreso de la subida en tiempo real:${NC}"
    echo -e "${YELLOW}  --------------------------------------------------------------------${NC}"
    echo ""
    
    # Execute rclone copy with detailed progress
    # -P: Show progress
    # --stats=1s: Update stats every second
    # --stats-one-line-date: Compact one-line stats with date
    # --transfers=4: 4 parallel file transfers
    # --checkers=8: 8 parallel checkers
    # --stats-file-name-length=40: Truncate filenames in stats
    rclone copy "${SOURCE_DIR}" "${REMOTE_NAME}:${REMOTE_PATH}" \
        --config="${RCLONE_CONFIG}" \
        -P \
        --stats=1s \
        --stats-one-line-date \
        --transfers=4 \
        --checkers=8 \
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
    print_section "PASO 8: RESUMEN FINAL"
    
    if [ ${RCLONE_EXIT_CODE} -eq 0 ]; then
        echo ""
        echo -e "${GREEN}  +================================================================+${NC}"
        echo -e "${GREEN}  |              SUBIDA COMPLETADA EXITOSAMENTE                   |${NC}"
        echo -e "${GREEN}  +================================================================+${NC}"
    else
        echo ""
        echo -e "${YELLOW}  +================================================================+${NC}"
        echo -e "${YELLOW}  |           SUBIDA COMPLETADA CON ADVERTENCIAS                  |${NC}"
        echo -e "${YELLOW}  +================================================================+${NC}"
    fi
    
    echo ""
    
    # Final statistics
    print_config_line "Hora de inicio" "$(date -d @${START_TIME} '+%Y-%m-%d %H:%M:%S')"
    print_config_line "Hora de fin" "$(date -d @${END_TIME} '+%Y-%m-%d %H:%M:%S')"
    print_config_line "Duracion total" "${DURATION_HUMAN}"
    
    echo ""
    
    # Check new state of Google Drive
    print_info "Verificando estado final de Google Drive..."
    FINAL_SIZE=$(rclone size "${REMOTE_NAME}:${REMOTE_PATH}" --config="${RCLONE_CONFIG}" --json 2>/dev/null || echo '{"count":0,"bytes":0}')
    FINAL_COUNT=$(echo "$FINAL_SIZE" | grep -oP '"count":\K[0-9]+' 2>/dev/null || echo "?")
    FINAL_BYTES=$(echo "$FINAL_SIZE" | grep -oP '"bytes":\K[0-9]+' 2>/dev/null || echo "0")
    
    if [ "$FINAL_BYTES" != "0" ]; then
        FINAL_SIZE_HUMAN=$(format_bytes $FINAL_BYTES)
        print_config_line "Archivos en GDrive" "${FINAL_COUNT} archivos"
        print_config_line "Tamano en GDrive" "${FINAL_SIZE_HUMAN}"
    fi
    
    echo ""
    echo -e "${BLUE}----------------------------------------------------------------------${NC}"
    echo -e "  ${CYAN}Comandos utiles:${NC}"
    echo -e "    Ver archivos en GDrive:  ${BOLD}rclone ls ${REMOTE_NAME}: --config=${RCLONE_CONFIG}${NC}"
    echo -e "    Listar carpetas:         ${BOLD}rclone lsd ${REMOTE_NAME}: --config=${RCLONE_CONFIG}${NC}"
    echo -e "    Ver espacio:             ${BOLD}rclone about ${REMOTE_NAME}: --config=${RCLONE_CONFIG}${NC}"
    echo -e "    Abrir en navegador:      ${BOLD}https://drive.google.com${NC}"
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
    check_gdrive_space
    analyze_destination
    show_configuration
    confirm_upload
    execute_upload
    print_summary
}

main "$@"

exit 0
