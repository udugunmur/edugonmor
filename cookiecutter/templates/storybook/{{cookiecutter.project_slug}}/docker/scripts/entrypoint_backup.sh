#!/bin/bash
set -e

# Setup cron job
echo "${CRON_SCHEDULE:-0 0 * * *} /backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/backup-cron
chmod 0644 /etc/cron.d/backup-cron
crontab /etc/cron.d/backup-cron

# Start cron
echo "Starting backup service with schedule: ${CRON_SCHEDULE:-0 0 * * *}"
cron -f
