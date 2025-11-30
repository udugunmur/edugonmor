#!/bin/bash
set -e

echo "********************************************************"
echo "*           Rclone Backup Container Started            *"
echo "********************************************************"

# Verificar variables críticas
if [ -z "$CRON_SCHEDULE" ]; then
    echo "ERROR: La variable CRON_SCHEDULE no está definida."
    exit 1
fi

echo "Configurando cron con horario: $CRON_SCHEDULE"

# Configurar crontab para el usuario root
# Se redirige la salida a los descriptores de archivo del proceso PID 1 (Docker logs)
# Se usa flock para evitar superponer ejecuciones si una sincronización larga sigue activa
echo "$CRON_SCHEDULE flock -n /tmp/rclone_backup.lock /scripts/backup.sh > /proc/1/fd/1 2> /proc/1/fd/2" > /etc/crontabs/root

echo "Versión de Rclone instalada:"
rclone --version

echo "Iniciando demonio crond en primer plano..."
echo "El próximo backup se ejecutará según el cronograma establecido."

# Ejecutar crond en foreground (-f) y nivel de log (-d)
exec crond -f -d 8
