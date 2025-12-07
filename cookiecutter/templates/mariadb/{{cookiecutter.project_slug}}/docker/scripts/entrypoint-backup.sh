#!/bin/bash
# ============================================================================
# MariaDB {{cookiecutter._mariadb_version}} - Backup Entrypoint
# ============================================================================
# Configura cron y ejecuta el scheduler
# ============================================================================

set -e

echo "=============================================="
echo "🗄️  MariaDB Backup Service Starting"
echo "=============================================="
echo "📅 Cron Schedule: ${CRON_SCHEDULE}"
echo "🔄 Retention: ${BACKUP_RETENTION} days"
echo "=============================================="

# Crear archivo de cron job
echo "${CRON_SCHEDULE} /usr/local/bin/backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/mariadb-backup

# Configurar permisos
chmod 0644 /etc/cron.d/mariadb-backup

# Aplicar cron job
crontab /etc/cron.d/mariadb-backup

# Crear archivo de log
touch /var/log/cron.log

# Exportar variables de entorno para cron
printenv | grep -E '^(MARIADB_|BACKUP_|CRON_|TZ)' >> /etc/environment

# Ejecutar backup inicial si está configurado
if [ "${INIT_BACKUP}" = "1" ] || [ "${INIT_BACKUP}" = "true" ]; then
    echo ""
    echo "🚀 Running initial backup..."
    /usr/local/bin/backup.sh || echo "⚠️ Initial backup failed, continuing..."
fi

echo ""
echo "✅ Cron service started. Waiting for scheduled backups..."
echo "   Next backup: ${CRON_SCHEDULE}"
echo ""

# Ejecutar cron en foreground
cron -f
