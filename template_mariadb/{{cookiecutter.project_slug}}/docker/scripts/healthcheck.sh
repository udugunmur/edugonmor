#!/bin/bash
set -e

if [ -n "$MARIADB_ROOT_PASSWORD" ]; then
    PASS="$MARIADB_ROOT_PASSWORD"
elif [ -n "$MARIADB_ROOT_PASSWORD_FILE" ]; then
    PASS=$(cat "$MARIADB_ROOT_PASSWORD_FILE")
else
    PASS=$(cat /run/secrets/db_password)
fi

# Check if MariaDB is ready
mariadb-admin ping -h localhost -u root --password="$PASS"
