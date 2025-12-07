#!/bin/bash
set -e

if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    PASS="$MYSQL_ROOT_PASSWORD"
elif [ -n "$MYSQL_ROOT_PASSWORD_FILE" ]; then
    PASS=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
else
    PASS=$(cat /run/secrets/db_password)
fi

# Check if MySQL is ready
export MYSQL_PWD="$PASS"
mysqladmin ping -h localhost -u root
