#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función de ayuda
show_help() {
    echo -e "${BLUE}Uso:${NC} ./subir_a_nube.sh [ARCHIVO_O_CARPETA_LOCAL] [DESTINO_REMOTO]"
    echo ""
    echo "Destinos disponibles:"
    echo "  1) onedrive-edugonmor"
    echo "  2) onedrive_backup"
    echo "  3) onedrive_data"
    echo "  4) onedrive_media"
    echo "  5) onedrive_business"
    echo "  6) gdrive-udugunmur"
    echo ""
    echo "Ejemplo: ./subir_a_nube.sh /home/usuario/mis_fotos.zip onedrive-edugonmor:/fotos"
}

# Verificar argumentos
if [ "$#" -lt 2 ]; then
    show_help
    exit 1
fi

SOURCE_PATH=$(realpath "$1")
REMOTE_DEST="$2"

# Verificar si el origen existe
if [ ! -e "$SOURCE_PATH" ]; then
    echo -e "${RED}Error: El archivo o directorio '$SOURCE_PATH' no existe.${NC}"
    exit 1
fi

# Determinar qué contenedor usar (usamos uno genérico que tenga acceso a rclone.conf)
# Usaremos 'rclone_onedrive_service' porque monta el config y tiene acceso a red host
CONTAINER_NAME="rclone_onedrive_service"

echo -e "${BLUE}Subiendo:${NC} $SOURCE_PATH"
echo -e "${BLUE}Destino:${NC} $REMOTE_DEST"
echo "----------------------------------------"

# Ejecutar rclone copy usando un contenedor efímero o uno existente
# Montamos el archivo/carpeta origen como volumen temporal solo para esta operación
if [ -d "$SOURCE_PATH" ]; then
    # Es un directorio
    DIR_NAME=$(basename "$SOURCE_PATH")
    docker run --rm -it \
        -v "$SOURCE_PATH":/source_data \
        -v "$(pwd)/config/rclone.conf":/root/.config/rclone/rclone.conf:ro \
        --network host \
        alpine:latest \
        sh -c "apk add --no-cache rclone && rclone copy /source_data \"$REMOTE_DEST\" -P"
else
    # Es un archivo
    FILE_DIR=$(dirname "$SOURCE_PATH")
    FILE_NAME=$(basename "$SOURCE_PATH")
    docker run --rm -it \
        -v "$FILE_DIR":/source_data \
        -v "$(pwd)/config/rclone.conf":/root/.config/rclone/rclone.conf:ro \
        --network host \
        alpine:latest \
        sh -c "apk add --no-cache rclone && rclone copy \"/source_data/$FILE_NAME\" \"$REMOTE_DEST\" -P"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Subida completada con éxito.${NC}"
    echo "El archivo aparecerá en tu carpeta sincronizada en la próxima ejecución del cron."
else
    echo -e "${RED}❌ Error al subir.${NC}"
fi
