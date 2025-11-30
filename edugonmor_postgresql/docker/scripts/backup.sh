#!/bin/bash
# ============================================================================
# Script de Backup PostgreSQL
# ============================================================================
# Documentación: https://www.postgresql.org/docs/16/backup.html
# Descripción: Realiza backup completo de PostgreSQL usando pg_dump

set -e

# Configuración
BACKUP_DIR="/home/edugonmor/repos/edugonmor_postgresql/backups"
CONTAINER_NAME="edugonmor_postgresql_services"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Cargar variables de entorno
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../docker/.env" ]; then
    export $(cat "$SCRIPT_DIR/../docker/.env" | grep -v '^#' | xargs)
fi

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}PostgreSQL Backup Script${NC}"
echo -e "${GREEN}============================================${NC}"
echo "Timestamp: $TIMESTAMP"
echo "Database: $POSTGRES_DB"
echo "User: $POSTGRES_USER"
echo "Backup Directory: $BACKUP_DIR"
echo -e "${GREEN}============================================${NC}"

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Verificar que el contenedor esté corriendo
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}Error: Contenedor $CONTAINER_NAME no está corriendo${NC}"
    exit 1
fi

# Realizar backup
BACKUP_FILE="$BACKUP_DIR/postgresql_${POSTGRES_DB}_${TIMESTAMP}.sql"
echo -n "Creando backup... "

if docker exec "$CONTAINER_NAME" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_FILE" 2>/dev/null; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}✓ OK${NC}"
    echo "Archivo: $BACKUP_FILE"
    echo "Tamaño: $BACKUP_SIZE"
else
    echo -e "${RED}✗ FAIL${NC}"
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Comprimir backup
echo -n "Comprimiendo backup... "
if gzip "$BACKUP_FILE"; then
    COMPRESSED_SIZE=$(du -h "$BACKUP_FILE.gz" | cut -f1)
    echo -e "${GREEN}✓ OK${NC}"
    echo "Archivo comprimido: $BACKUP_FILE.gz"
    echo "Tamaño comprimido: $COMPRESSED_SIZE"
else
    echo -e "${YELLOW}⚠ Warning: No se pudo comprimir${NC}"
fi

# Limpiar backups antiguos (mantener últimos 7 días)
echo -n "Limpiando backups antiguos (>7 días)... "
DELETED=$(find "$BACKUP_DIR" -name "postgresql_*.sql.gz" -mtime +7 -delete -print | wc -l)
echo -e "${GREEN}✓ OK${NC} ($DELETED archivos eliminados)"

# Backup de configuración
CONFIG_BACKUP="$BACKUP_DIR/postgresql_conf_${TIMESTAMP}.tar.gz"
echo -n "Backup de configuración... "
if tar -czf "$CONFIG_BACKUP" \
    -C "$SCRIPT_DIR/.." \
    postgresql.conf \
    docker/.env.example \
    2>/dev/null; then
    echo -e "${GREEN}✓ OK${NC}"
    echo "Configuración: $CONFIG_BACKUP"
else
    echo -e "${YELLOW}⚠ Warning: No se pudo crear backup de configuración${NC}"
fi

# Listar backups recientes
echo ""
echo -e "${GREEN}============================================${NC}"
echo "Backups recientes:"
echo -e "${GREEN}============================================${NC}"
ls -lht "$BACKUP_DIR" | head -n 6

echo ""
echo -e "${GREEN}Backup completado exitosamente${NC}"

# Mostrar comando de restauración
echo ""
echo -e "${YELLOW}Para restaurar este backup:${NC}"
echo "gunzip < $BACKUP_FILE.gz | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d $POSTGRES_DB"
