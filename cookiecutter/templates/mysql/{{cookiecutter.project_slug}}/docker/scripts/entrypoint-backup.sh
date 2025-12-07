#!/bin/bash
set -e

# Configurar cron
echo "Configurando CRON SCHEDULE: ${CRON_SCHEDULE}"

# Crear archivo crontab
# Redirigir stdout/stderr a proc/1/fd/1 para ver logs en docker logs
echo "${CRON_SCHEDULE} root /usr/local/bin/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/backup-cron

# Dar permisos correctos
chmod 0644 /etc/cron.d/backup-cron
crontab /etc/cron.d/backup-cron

echo "[$(date)] Iniciando Backup Service (Cron)..."

# Ejecutar backup inicial si se solicita
if [ "${INIT_BACKUP}" = "1" ] || [ "${INIT_BACKUP}" = "true" ]; then
    echo "[$(date)] Ejecutando backup inicial..."
    /usr/local/bin/backup.sh
fi

# Iniciar cron en primer plano (crond en Alpine/RedHat)
exec crond -n
