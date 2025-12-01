#!/bin/bash
#
# configure-rclone.sh - Configuración interactiva de remotos Rclone
#
# Uso: ./configure-rclone.sh
#
# Descripción:
#   Guía interactiva para configurar:
#   - Google Drive (udugunmur)
#   - OneDrive (edugonmor)
#

set -e

echo "=========================================="
echo "  Configuración de Remotos Rclone"
echo "=========================================="
echo ""

# Verificar que rclone está instalado
if ! command -v rclone &> /dev/null; then
    echo "[ERROR] Rclone no está instalado"
    echo "Ejecuta primero: sudo ./scripts/install-rclone.sh"
    exit 1
fi

# Menú principal
show_menu() {
    echo ""
    echo "Selecciona una opción:"
    echo ""
    echo "  1) Configurar Google Drive (udugunmur)"
    echo "  2) Configurar OneDrive (edugonmor)"
    echo "  3) Ver remotos configurados"
    echo "  4) Probar conexión de remotos"
    echo "  5) Sincronizar config con Docker"
    echo "  6) Salir"
    echo ""
    read -p "Opción [1-6]: " OPTION
}

# Configurar Google Drive
configure_gdrive() {
    echo ""
    echo "=========================================="
    echo "  Configuración de Google Drive"
    echo "=========================================="
    echo ""
    echo "INSTRUCCIONES:"
    echo ""
    echo "1. Se abrirá el navegador para autenticarte en Google"
    echo "2. Inicia sesión con la cuenta: udugunmur@gmail.com"
    echo "3. Autoriza el acceso a Google Drive"
    echo "4. Vuelve a esta terminal cuando termine"
    echo ""
    read -p "Presiona ENTER para continuar..."
    
    # Verificar si ya existe
    if rclone listremotes | grep -q "gdrive-udugunmur:"; then
        echo ""
        echo "[WARN] El remoto 'gdrive-udugunmur' ya existe"
        read -p "¿Quieres reconfigurarlo? [s/N]: " RECONFIG
        if [[ ! "$RECONFIG" =~ ^[Ss]$ ]]; then
            echo "Cancelado."
            return
        fi
        rclone config delete gdrive-udugunmur
    fi
    
    echo ""
    echo "Iniciando configuración de Google Drive..."
    echo ""
    
    # Configuración automática
    rclone config create gdrive-udugunmur drive \
        scope drive \
        --all
    
    echo ""
    echo "[OK] Google Drive configurado como 'gdrive-udugunmur'"
    echo ""
    echo "Punto de montaje: /mnt/disk2/rclone/gdrive"
}

# Configurar OneDrive
configure_onedrive() {
    echo ""
    echo "=========================================="
    echo "  Configuración de OneDrive"
    echo "=========================================="
    echo ""
    echo "INSTRUCCIONES:"
    echo ""
    echo "1. Se abrirá el navegador para autenticarte en Microsoft"
    echo "2. Inicia sesión con la cuenta: edugonmor@outlook.com"
    echo "3. Autoriza el acceso a OneDrive"
    echo "4. Vuelve a esta terminal cuando termine"
    echo ""
    read -p "Presiona ENTER para continuar..."
    
    # Verificar si ya existe
    if rclone listremotes | grep -q "onedrive-edugonmor:"; then
        echo ""
        echo "[WARN] El remoto 'onedrive-edugonmor' ya existe"
        read -p "¿Quieres reconfigurarlo? [s/N]: " RECONFIG
        if [[ ! "$RECONFIG" =~ ^[Ss]$ ]]; then
            echo "Cancelado."
            return
        fi
        rclone config delete onedrive-edugonmor
    fi
    
    echo ""
    echo "Iniciando configuración de OneDrive..."
    echo ""
    
    # Configuración automática
    rclone config create onedrive-edugonmor onedrive \
        --all
    
    echo ""
    echo "[OK] OneDrive configurado como 'onedrive-edugonmor'"
    echo ""
    echo "Punto de montaje: /mnt/disk2/rclone/onedrive"
}

# Listar remotos
list_remotes() {
    echo ""
    echo "=========================================="
    echo "  Remotos Configurados"
    echo "=========================================="
    echo ""
    REMOTES=$(rclone listremotes)
    if [ -z "$REMOTES" ]; then
        echo "[INFO] No hay remotos configurados"
    else
        echo "$REMOTES"
        echo ""
        echo "Archivo de configuración: ~/.config/rclone/rclone.conf"
    fi
}

# Probar conexión
test_remotes() {
    echo ""
    echo "=========================================="
    echo "  Probando Conexión de Remotos"
    echo "=========================================="
    echo ""
    
    if rclone listremotes | grep -q "gdrive-udugunmur:"; then
        echo -n "gdrive-udugunmur: "
        if rclone lsd gdrive-udugunmur: --max-depth 1 &> /dev/null; then
            echo "[OK] Conectado"
        else
            echo "[FAIL] Error de conexión"
        fi
    else
        echo "gdrive-udugunmur: [NO CONFIGURADO]"
    fi
    
    if rclone listremotes | grep -q "onedrive-edugonmor:"; then
        echo -n "onedrive-edugonmor: "
        if rclone lsd onedrive-edugonmor: --max-depth 1 &> /dev/null; then
            echo "[OK] Conectado"
        else
            echo "[FAIL] Error de conexión"
        fi
    else
        echo "onedrive-edugonmor: [NO CONFIGURADO]"
    fi
}

# Sincronizar con Docker
sync_docker() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$SCRIPT_DIR/sync-rclone-config.sh" ]; then
        "$SCRIPT_DIR/sync-rclone-config.sh"
    else
        echo "[ERROR] Script sync-rclone-config.sh no encontrado"
    fi
}

# Loop principal
while true; do
    show_menu
    case $OPTION in
        1)
            configure_gdrive
            ;;
        2)
            configure_onedrive
            ;;
        3)
            list_remotes
            ;;
        4)
            test_remotes
            ;;
        5)
            sync_docker
            ;;
        6)
            echo ""
            echo "¡Hasta luego!"
            exit 0
            ;;
        *)
            echo "[ERROR] Opción no válida"
            ;;
    esac
done
