#!/bin/bash
# ============================================================================
# Entrypoint para contenedor de Backup MongoDB
# ============================================================================
# Configura cron y ejecuta el scheduler

set -e

echo "============================================"
echo "MongoDB Backup Container - Iniciando"
echo "============================================"
echo "Schedule: ${CRON_SCHEDULE:-0 3 * * *}"
echo "Retention: ${BACKUP_RETENTION:-10} days"
echo "============================================"

# Configurar cron job
CRON_SCHEDULE="${CRON_SCHEDULE:-0 3 * * *}"

# Crear archivo de cron con las variables de entorno
cat > /etc/cron.d/mongodb-backup << EOF
# MongoDB Backup Cron Job
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MONGO_HOST=${MONGO_HOST}
MONGO_PORT=${MONGO_PORT}
MONGO_USER=${MONGO_USER}
MONGO_PASSWORD=${MONGO_PASSWORD}
BACKUP_DIR=/backup
BACKUP_RETENTION=${BACKUP_RETENTION}

${CRON_SCHEDULE} root /usr/local/bin/backup.sh >> /var/log/mongodb-backup.log 2>&1
EOF

# Dar permisos correctos al archivo cron
chmod 0644 /etc/cron.d/mongodb-backup

# Crear archivo de log
touch /var/log/mongodb-backup.log

echo "[INFO] Cron job configurado: ${CRON_SCHEDULE}"
echo "[INFO] Ejecutando backup inicial..."

# Ejecutar backup inicial (opcional, comentar si no se desea)
/usr/local/bin/backup.sh || echo "[WARN] Backup inicial falló (el servicio MongoDB puede no estar listo aún)"

echo "[INFO] Iniciando servicio cron..."
echo "============================================"

# Ejecutar cron en foreground
exec cron -f
