#!/bin/bash
# =============================================================================
# install-samba.sh
# Instala y configura Samba para compartir archivos vía SMB
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# CONFIGURACIÓN
# =============================================================================
SMB_USER="${SUDO_USER:-edugonmor}"
SMB_CONF="/etc/samba/smb.conf"
SMB_CONF_BACKUP="/etc/samba/smb.conf.backup"

# Shares a configurar (añadir más según necesidad)
declare -A SHARES=(
    ["home"]="/home/${SMB_USER}"
    ["disk1"]="/mnt/disk1"
    ["disk2"]="/mnt/disk2"
)

# =============================================================================
# VERIFICACIONES
# =============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root (sudo)"
        exit 1
    fi
}

# =============================================================================
# INSTALACIÓN
# =============================================================================

install_samba() {
    log_info "Instalando Samba..."
    apt-get update -qq
    apt-get install -y samba samba-common-bin
    log_success "Samba instalado"
}

# =============================================================================
# CONFIGURACIÓN
# =============================================================================

backup_config() {
    if [[ -f "$SMB_CONF" && ! -f "$SMB_CONF_BACKUP" ]]; then
        log_info "Creando backup de configuración original..."
        cp "$SMB_CONF" "$SMB_CONF_BACKUP"
        log_success "Backup creado: $SMB_CONF_BACKUP"
    fi
}

configure_samba() {
    log_info "Configurando Samba..."
    
    # Crear configuración base
    cat > "$SMB_CONF" << 'EOF'
# =============================================================================
# Samba Configuration - Linux Server
# Generado por: install-samba.sh
# =============================================================================

[global]
   workgroup = WORKGROUP
   server string = Linux Server
   server role = standalone server
   
   # Seguridad
   security = user
   map to guest = never
   
   # Logging
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file
   
   # Performance
   socket options = TCP_NODELAY IPTOS_LOWDELAY
   read raw = yes
   write raw = yes
   
   # macOS Compatibility (Fruit VFS)
   vfs objects = fruit streams_xattr
   fruit:metadata = stream
   fruit:model = MacSamba
   fruit:posix_rename = yes
   fruit:veto_appledouble = yes
   fruit:wipe_intentionally_left_blank_rfork = yes
   fruit:delete_empty_adfiles = yes
   fruit:nfs_aces = no
   
   # Character encoding
   unix charset = UTF-8
   dos charset = CP850

EOF

    # Añadir shares configurados
    for share_name in "${!SHARES[@]}"; do
        share_path="${SHARES[$share_name]}"
        
        # Solo añadir si el directorio existe
        if [[ -d "$share_path" ]]; then
            log_info "Añadiendo share: [$share_name] -> $share_path"
            
            cat >> "$SMB_CONF" << EOF

[$share_name]
   comment = ${share_name} share
   path = $share_path
   browseable = yes
   read only = no
   writable = yes
   valid users = ${SMB_USER}
   
   # MODO DIOS - Permisos absolutos
   admin users = ${SMB_USER}
   create mask = 0777
   directory mask = 0777
   force create mode = 0777
   force directory mode = 0777
   force user = root
   force group = root
   
   # Borrar todo sin restricciones
   delete readonly = yes
   delete veto files = yes
   veto files = /._*/.DS_Store/.Thumbs.db/.AppleDouble/.TemporaryItems/
   
   # Herencia de permisos
   inherit permissions = yes
   inherit owner = yes
   inherit acls = yes
EOF
        else
            log_warn "Directorio no existe, omitiendo: $share_path"
        fi
    done
    
    log_success "Configuración de Samba completada"
}

# =============================================================================
# USUARIO SAMBA
# =============================================================================

setup_samba_user() {
    log_info "Configurando usuario Samba: ${SMB_USER}"
    
    # Verificar que el usuario existe en el sistema
    if ! id "$SMB_USER" &>/dev/null; then
        log_error "Usuario '$SMB_USER' no existe en el sistema"
        exit 1
    fi
    
    # Añadir usuario a Samba (pide contraseña interactivamente)
    echo ""
    log_warn "Introduce la contraseña SMB para el usuario '${SMB_USER}':"
    smbpasswd -a "$SMB_USER"
    smbpasswd -e "$SMB_USER"
    
    log_success "Usuario Samba configurado"
}

# =============================================================================
# SERVICIOS
# =============================================================================

restart_services() {
    log_info "Reiniciando servicios Samba..."
    systemctl restart smbd nmbd
    systemctl enable smbd nmbd
    log_success "Servicios reiniciados y habilitados"
}

# =============================================================================
# VERIFICACIÓN
# =============================================================================

verify_installation() {
    log_info "Verificando instalación..."
    
    echo ""
    echo "=== Estado de servicios ==="
    systemctl status smbd --no-pager -l | head -5
    echo ""
    
    echo "=== Shares configurados ==="
    testparm -s 2>/dev/null | grep -E "^\[" || true
    echo ""
    
    echo "=== Conexión desde Mac ==="
    local IP=$(hostname -I | awk '{print $1}')
    echo "  Finder → Ir → Conectar al servidor..."
    echo "  smb://${IP}"
    echo ""
    echo "  O desde Terminal:"
    echo "  open smb://${IP}"
    echo ""
    
    log_success "Instalación verificada"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    echo ""
    echo "=============================================="
    echo "  🗂️  Instalación de Samba (SMB Server)"
    echo "=============================================="
    echo ""
    
    check_root
    install_samba
    backup_config
    configure_samba
    setup_samba_user
    restart_services
    verify_installation
    
    echo ""
    log_success "¡Samba instalado y configurado correctamente!"
    echo ""
}

main "$@"
