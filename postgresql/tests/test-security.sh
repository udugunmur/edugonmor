#!/bin/bash
set -e

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CONTAINER_NAME="postgresql_services"
POSTGRES_USER="postgres"

echo "========================================================================"
echo "Iniciando Tests de Seguridad (RBAC y Auditoría)"
echo "========================================================================"

# Función auxiliar para ejecutar SQL
exec_sql() {
    docker exec "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d postgres -tAc "$1"
}

# 1. Verificar Roles
echo -n "1. Verificando existencia de roles (app_reader, app_writer)... "
ROLES_COUNT=$(exec_sql "SELECT COUNT(*) FROM pg_roles WHERE rolname IN ('app_reader', 'app_writer')")

if [ "$ROLES_COUNT" -eq "2" ]; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Encontrados: $ROLES_COUNT/2)"
    exit 1
fi

# 2. Verificar Asignación de Roles
TARGET_USER="test_user"
TARGET_ROLE="app_writer"
echo -n "2. Verificando que '$TARGET_USER' tiene rol '$TARGET_ROLE'... "

IS_MEMBER=$(exec_sql "SELECT pg_has_role('$TARGET_USER', '$TARGET_ROLE', 'MEMBER')")

if [ "$IS_MEMBER" == "t" ]; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[FAIL]${NC}"
    exit 1
fi

# 3. Verificar Configuración de Auditoría
echo "3. Verificando parámetros de auditoría en runtime..."

check_param() {
    local param="$1"
    local expected="$2"
    echo -n "   - $param = $expected... "
    local actual=$(exec_sql "SHOW $param")
    
    if [ "$actual" == "$expected" ]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAIL]${NC} (Actual: $actual)"
        exit 1
    fi
}

check_param "log_connections" "on"
check_param "log_disconnections" "on"
check_param "log_statement" "ddl"

echo "========================================================================"
echo -e "${GREEN}Todos los tests de seguridad pasaron correctamente.${NC}"
echo "========================================================================"
