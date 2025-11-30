#!/bin/bash
set -e

# Setup cron
echo "${SCHEDULE} /backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/nexus-backup
chmod 0644 /etc/cron.d/nexus-backup
crontab /etc/cron.d/nexus-backup

# Create log file
touch /var/log/cron.log

# Start cron
echo "Starting cron..."
cron -f
