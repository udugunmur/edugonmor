#!/bin/bash
# Script de verificación previa al despliegue
set -e

echo "🔍 Iniciando comprobación de requisitos..."

# 1. Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado."
    exit 1
else
    echo "✅ Docker detectado."
fi

# 2. Verificar Volumen de Datos Sensibles
if docker volume inspect datos_sensibles &> /dev/null; then
    echo "✅ Volumen Docker 'datos_sensibles' encontrado."
else
    echo "⚠️  Volumen Docker 'datos_sensibles' NO encontrado."
    echo "   Creándolo ahora para evitar errores (asegúrate de llenarlo con datos)..."
    docker volume create datos_sensibles
fi

# 3. Verificar Directorios de Destino OneDrive (todas las cuentas)
ONEDRIVE_DIRS=(
  "/mnt/disk2/rclone/onedrive/edugonmor"
  "/mnt/disk2/rclone/onedrive/edugonmor_backup"
  "/mnt/disk2/rclone/onedrive/edugonmor_data"
  "/mnt/disk2/rclone/onedrive/edugonmor_media"
  "/mnt/disk2/rclone/onedrive/edugonmor_business"
  "/mnt/disk2/rclone/gdrive/udugunmur"
)
for DIR in "${ONEDRIVE_DIRS[@]}"; do
  if [ -d "$DIR" ]; then
      echo "✅ Directorio de destino Cloud encontrado: $DIR"
  else
      echo "❌ Directorio de destino Cloud NO encontrado: $DIR"
      echo "   Ejecuta: mkdir -p $DIR"
      exit 1
  fi
done

# 4. Verificar Configuración Rclone
RCLONE_CONF="./docker/config/rclone.conf"
if [ -f "$RCLONE_CONF" ]; then
    echo "✅ Archivo de configuración rclone.conf encontrado."
    REMOTES=(
      "[onedrive-edugonmor]"
      "[onedrive_backup]"
      "[onedrive_data]"
      "[onedrive_media]"
      "[onedrive_business]"
      "[gdrive-udugunmur]"
    )
    for REMOTE in "${REMOTES[@]}"; do
      if grep -q "$REMOTE" "$RCLONE_CONF"; then
          echo "✅ Configuración detectada: $REMOTE"
      else
          echo "⚠️  No se detectó la sección $REMOTE en rclone.conf."
      fi
    done
else
    echo "❌ Archivo $RCLONE_CONF NO encontrado."
    echo "   Debes crear este archivo con tus credenciales antes de desplegar."
    echo "   Usa docker/config/rclone.conf.example como guía."
    exit 1
fi

echo "------------------------------------------------"
echo "🚀 Todo parece estar listo. Puedes desplegar con:"
echo "   cd docker && docker-compose up -d"
echo "------------------------------------------------"
