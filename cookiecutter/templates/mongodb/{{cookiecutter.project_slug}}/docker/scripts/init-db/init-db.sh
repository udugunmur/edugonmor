#!/bin/bash
# ============================================================================
# MongoDB {{cookiecutter.mongo_version}} - Database Initialization Script
# ============================================================================
# Maintainer: edugonmor
# Version: {{cookiecutter.mongo_version}}
# Last Updated: 2025-12-04
# Description: Initializes database, users, and sample collections
# ============================================================================

set -e

# Esperar a que MongoDB esté listo
echo "⏳ Waiting for MongoDB to be ready..."
sleep 5

# Conexión como root
MONGO_HOST="localhost"
MONGO_PORT="27017"
MONGO_URI="mongodb://${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}"

echo "🔧 Initializing MongoDB {{cookiecutter.mongo_version}}..."

# Crear base de datos y usuario de aplicación
mongosh "${MONGO_URI}/admin" <<EOF
// Crear base de datos de aplicación
use ${MONGO_INITDB_DATABASE}

// Crear usuario de aplicación con permisos readWrite
db.createUser({
    user: "app_user",
    pwd: "app_password_dev",
    roles: [
        { role: "readWrite", db: "${MONGO_INITDB_DATABASE}" }
    ]
})

// Crear usuario de solo lectura
db.createUser({
    user: "readonly_user", 
    pwd: "readonly_password_dev",
    roles: [
        { role: "read", db: "${MONGO_INITDB_DATABASE}" }
    ]
})

// Crear colección de configuración con datos iniciales
db.config.insertMany([
    {
        key: "app_version",
        value: "1.0.0",
        description: "Application version",
        created_at: new Date()
    },
    {
        key: "project_name",
        value: "{{cookiecutter.project_name}}",
        description: "Project name",
        created_at: new Date()
    }
])

// Crear índice único en la colección config
db.config.createIndex({ key: 1 }, { unique: true })

print("✅ Database initialization complete!")
print("📊 Created database: ${MONGO_INITDB_DATABASE}")
print("👤 Created users: app_user, readonly_user")
print("📁 Created collection: config")
EOF

echo "✅ MongoDB initialization completed successfully!"
