#!/bin/bash
# ============================================================================
# Script de Inicialización PostgreSQL
# ============================================================================
# Documentación: https://www.postgresql.org/docs/16/
# Este script se ejecuta automáticamente durante la primera inicialización.
#
# Ubicación en contenedor: /docker-entrypoint-initdb.d/01-init.sh

set -e

# 1. Crear extensiones en la base de datos principal
echo "Configurando extensiones en $POSTGRES_DB..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
EOSQL

# 2. Ejecutar sincronización de configuración (Usuarios y DBs)
# Delegamos la lógica al script centralizado para evitar duplicidad
if [ -f /usr/local/bin/sync-db-config ]; then
    /usr/local/bin/sync-db-config
else
    echo "Error: Script de sincronización no encontrado."
fi

echo "Inicialización inicial completada exitosamente"
