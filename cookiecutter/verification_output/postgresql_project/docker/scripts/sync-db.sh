#!/bin/bash
set -e

# Configuración
CONFIG_FILE="/etc/postgresql-custom/init-data.json"
PROCESSED_CONFIG="/tmp/init-data-processed.json"

# Funciones auxiliares
create_database_if_not_exists() {
    local dbname="$1"
    local owner="$2"
    
    if psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -tAc "SELECT 1 FROM pg_database WHERE datname = '$dbname'" | grep -q 1; then
        echo "   [OK] Base de datos '$dbname' ya existe."
    else
        echo "   [NEW] Creando base de datos '$dbname'..."
        if [ -n "$owner" ]; then
            psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -c "CREATE DATABASE \"$dbname\" OWNER \"$owner\""
        else
            psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -c "CREATE DATABASE \"$dbname\""
        fi
    fi
}

create_user_if_not_exists() {
    local username="$1"
    local password="$2"
    
    if psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -tAc "SELECT 1 FROM pg_roles WHERE rolname = '$username'" | grep -q 1; then
        echo "   [OK] Usuario '$username' ya existe."
        # Opcional: Actualizar contraseña si cambia (comentado por seguridad/idempotencia simple)
        # psql ... -c "ALTER USER \"$username\" WITH PASSWORD '$password'"
    else
        echo "   [NEW] Creando usuario '$username'..."
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -c "CREATE USER \"$username\" WITH PASSWORD '$password'"
    fi
}

create_role_if_not_exists() {
    local rolename="$1"
    
    if psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -tAc "SELECT 1 FROM pg_roles WHERE rolname = '$rolename'" | grep -q 1; then
        echo "   [OK] Rol '$rolename' ya existe."
    else
        echo "   [NEW] Creando rol '$rolename'..."
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -c "CREATE ROLE \"$rolename\" NOLOGIN"
    fi
}

grant_role_to_user() {
    local role="$1"
    local user="$2"
    
    echo "   [GRANT] Asignando rol '$role' a usuario '$user'..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -c "GRANT \"$role\" TO \"$user\""
}

echo "========================================================================"
echo "Iniciando sincronización de configuración de base de datos..."
echo "========================================================================"

# Esperar a que Postgres esté listo (necesario si se ejecuta al arranque)
until pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; do
    echo "Esperando a que PostgreSQL esté listo..."
    sleep 2
done

# Procesar JSON
if [ -f "$CONFIG_FILE" ]; then
    echo "Cargando configuración desde $CONFIG_FILE..."
    
    # Sustitución de variables
    envsubst < "$CONFIG_FILE" > "$PROCESSED_CONFIG"

    # 0) Roles (Nuevo: Sistema de Seguridad RBAC)
    echo "-> Procesando roles..."
    if jq -e '.roles' "$PROCESSED_CONFIG" > /dev/null; then
        while IFS= read -r role_json; do
            rolename=$(echo "$role_json" | jq -r '.name')
            if [ -n "$rolename" ] && [ "$rolename" != "null" ]; then
                create_role_if_not_exists "$rolename"
            fi
        done < <(jq -c '.roles[]' "$PROCESSED_CONFIG")
    fi

    # A) Usuarios y sus DBs
    while IFS= read -r user_json; do
        username=$(echo "$user_json" | jq -r '.username')
        password=$(echo "$user_json" | jq -r '.password')
        role=$(echo "$user_json" | jq -r '.role')
        
        if [ -n "$username" ] && [ -n "$password" ] && [ "$username" != "null" ]; then
            echo "-> Procesando usuario: $username"
            create_user_if_not_exists "$username" "$password"
            
            if [ -n "$role" ] && [ "$role" != "null" ]; then
                 grant_role_to_user "$role" "$username"
            fi
            
            echo "$user_json" | jq -r '.databases[]' | while read -r dbname; do
                if [ -n "$dbname" ] && [ "$dbname" != "null" ]; then
                    create_database_if_not_exists "$dbname" "$username"
                fi
            done
        fi
    done < <(jq -c '.users[]' "$PROCESSED_CONFIG")

    # B) Bases de datos adicionales
    echo "-> Procesando bases de datos adicionales..."
    while IFS= read -r db_json; do
        dbname=$(echo "$db_json" | jq -r '.name')
        owner=$(echo "$db_json" | jq -r '.owner')
        
        if [ -z "$owner" ] || [ "$owner" == "null" ]; then
            owner="$POSTGRES_USER"
        fi

        if [ -n "$dbname" ] && [ "$dbname" != "null" ]; then
            create_database_if_not_exists "$dbname" "$owner"
        fi
    done < <(jq -c '.additional_databases[]' "$PROCESSED_CONFIG")

else
    echo "Archivo de configuración JSON no encontrado."
fi

# Compatibilidad Legacy
if [ -n "$APP_DB_NAME" ]; then
    echo "-> Procesando configuración Legacy (APP_DB_NAME)..."
    if [ -n "$APP_DB_USER" ] && [ -n "$APP_DB_PASSWORD" ]; then
        create_user_if_not_exists "$APP_DB_USER" "$APP_DB_PASSWORD"
        create_database_if_not_exists "$APP_DB_NAME" "$APP_DB_USER"
    else
        create_database_if_not_exists "$APP_DB_NAME" "$POSTGRES_USER"
    fi
fi

echo "========================================================================"
echo "Sincronización completada."
echo "========================================================================"
