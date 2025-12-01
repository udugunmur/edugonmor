#!/bin/bash
set -e

# Configuración
CONFIG_FILE="/etc/mongo-custom/init-data.json"
PROCESSED_CONFIG="/tmp/init-data-processed.json"

echo "========================================================================"
echo "Iniciando sincronización de configuración de MongoDB..."
echo "========================================================================"

# Procesar JSON
if [ -f "$CONFIG_FILE" ]; then
    echo "Cargando configuración desde $CONFIG_FILE..."
    
    # Sustitución de variables
    envsubst < "$CONFIG_FILE" > "$PROCESSED_CONFIG"

    # Procesar usuarios
    jq -c '.users[]' "$PROCESSED_CONFIG" | while read -r user_json; do
        username=$(echo "$user_json" | jq -r '.username')
        password=$(echo "$user_json" | jq -r '.password')
        role=$(echo "$user_json" | jq -r '.role')
        
        if [ -n "$username" ] && [ -n "$password" ] && [ "$username" != "null" ]; then
            echo "-> Procesando usuario: $username"
            
            # Iterar sobre las bases de datos del usuario
            echo "$user_json" | jq -r '.databases[]' | while read -r dbname; do
                if [ -n "$dbname" ] && [ "$dbname" != "null" ]; then
                    echo "   [DB] Configurando usuario en base de datos '$dbname'..."
                    
                    mongosh "$dbname" \
                        --host localhost \
                        --authenticationDatabase admin \
                        -u "$MONGO_INITDB_ROOT_USERNAME" \
                        -p "$MONGO_INITDB_ROOT_PASSWORD" \
                        --eval "
                        try {
                            db.createUser({
                                user: '$username',
                                pwd: '$password',
                                roles: [{ role: '$role', db: '$dbname' }]
                            });
                            print('   [NEW] Usuario creado exitosamente.');
                        } catch (e) {
                            if (e.code === 51003) { // UserAlreadyExists
                                print('   [OK] El usuario ya existe.');
                                // Opcional: Actualizar contraseña/roles
                            } else {
                                print('   [ERROR] ' + e);
                                throw e;
                            }
                        }
                    "
                fi
            done
        fi
    done
else
    echo "No se encontró archivo de configuración en $CONFIG_FILE"
fi

echo "Sincronización completada."
