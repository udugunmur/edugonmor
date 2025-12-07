#!/bin/bash
# ============================================================================
# Test de Conexión PostgreSQL
# ============================================================================
# Descripción: Script para probar la conexión a PostgreSQL
# Documentación: https://www.postgresql.org/docs/{{cookiecutter._postgres_version}}/

set -e

# Cargar variables de entorno
if [ -f "../docker/.env" ]; then
    export $(cat ../docker/.env | grep -v '^#' | xargs)
fi

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

echo "============================================"
echo "Test de Conexión PostgreSQL"
echo "============================================"
echo "Host: $POSTGRES_HOST"
echo "Port: $POSTGRES_PORT"
echo "User: $POSTGRES_USER"
echo "Database: $POSTGRES_DB"
echo "============================================"

# Test 1: Verificar si el puerto está abierto
echo -n "Test 1: Puerto accesible... "
if nc -z "$POSTGRES_HOST" "$POSTGRES_PORT" 2>/dev/null; then
    echo "✓ OK"
else
    echo "✗ FAIL - Puerto no accesible"
    exit 1
fi

# Test 2: pg_isready
echo -n "Test 2: PostgreSQL listo... "
if docker exec postgresql_services pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; then
    echo "✓ OK"
else
    echo "✗ FAIL - PostgreSQL no responde"
    exit 1
fi

# Test 3: Conexión SQL
echo -n "Test 3: Consulta SQL... "
RESULT=$(docker exec postgresql_services psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT version();" 2>/dev/null)
if [ -n "$RESULT" ]; then
    echo "✓ OK"
    echo "   Versión: ${RESULT:0:50}..."
else
    echo "✗ FAIL - No se pudo ejecutar consulta"
    exit 1
fi

# Test 4: Verificar extensiones disponibles
echo -n "Test 4: Extensiones disponibles... "
EXT_COUNT=$(docker exec postgresql_services psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT count(*) FROM pg_available_extensions;" 2>/dev/null)
if [ -n "$EXT_COUNT" ]; then
    echo "✓ OK ($EXT_COUNT extensiones)"
else
    echo "✗ FAIL"
    exit 1
fi

echo "============================================"
echo "Todos los tests pasaron correctamente"
echo "============================================"
