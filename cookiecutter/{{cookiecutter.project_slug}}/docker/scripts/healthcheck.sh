#!/bin/bash
set -e

# Determine password source
if [ -n "$MARIADB_ROOT_PASSWORD" ]; then
    PASSWORD="$MARIADB_ROOT_PASSWORD"
elif [ -n "$MARIADB_ROOT_PASSWORD_FILE" ]; then
    PASSWORD=$(cat "$MARIADB_ROOT_PASSWORD_FILE")
else
    echo "Error: No password variable set"
    exit 1
fi

# Check if MariaDB is ready
mariadb-admin ping -h localhost -u root --password="$PASSWORD"
