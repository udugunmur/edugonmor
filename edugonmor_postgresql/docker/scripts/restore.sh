#!/bin/bash
# ============================================================================
# Script de Restauración PostgreSQL
# ============================================================================
# Documentación: https://www.postgresql.org/docs/16/backup.html
# Descripción: Restaura backup de PostgreSQL desde archivo .sql o .sql.gz

set -e

# Configuración
CONTAINER_NAME="edugonmor_postgresql_services"

# Cargar variables de entorno
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../docker/.env" ]; then
    export $(cat "$SCRIPT_DIR/../docker/.env" | grep -v '^#' | xargs)
fi

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar argumento
if [ -z "$1" ]; then
    echo -e "${RED}Error: Debes especificar el archivo de backup${NC}"
    echo ""
    echo "Uso: $0 <archivo_backup.sql[.gz]>"
    echo ""
    echo "Ejemplo:"
    echo "  $0 backups/postgresql_postgres_20251118_120000.sql.gz"
    exit 1
fi

BACKUP_FILE="$1"

# Verificar que el archivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: El archivo $BACKUP_FILE no existe${NC}"
    exit 1
fi

echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}⚠️  ADVERTENCIA - Restauración PostgreSQL${NC}"
echo -e "${YELLOW}============================================${NC}"
echo "Esta operación:"
echo "  - Eliminará TODOS los datos actuales de la base de datos"
echo "  - Restaurará el backup: $(basename "$BACKUP_FILE")"
echo "  - Base de datos: $POSTGRES_DB"
echo ""
read -p "¿Estás seguro? (escribe 'SI' para continuar): " CONFIRM

if [ "$CONFIRM" != "SI" ]; then
    echo -e "${GREEN}Operación cancelada${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Iniciando restauración${NC}"
echo -e "${GREEN}============================================${NC}"

# Verificar que el contenedor esté corriendo
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}Error: Contenedor $CONTAINER_NAME no está corriendo${NC}"
    exit 1
fi

# Determinar si el archivo está comprimido
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "Detectado archivo comprimido (.gz)"
    echo -n "Restaurando desde backup comprimido... "
    if gunzip < "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
    else
        echo -e "${RED}✗ FAIL${NC}"
        exit 1
    fi
else
    echo "Detectado archivo SQL sin comprimir"
    echo -n "Restaurando desde backup... "
    if cat "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
    else
        echo -e "${RED}✗ FAIL${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Restauración completada exitosamente${NC}"
echo -e "${GREEN}============================================${NC}"
