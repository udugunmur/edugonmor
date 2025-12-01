#!/bin/bash
set -e

CONFIG_FILE="/etc/mysql/custom/init-data.json"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 0
fi

# Determine root password
if [ -n "$MARIADB_ROOT_PASSWORD" ]; then
    ROOT_PASS="$MARIADB_ROOT_PASSWORD"
else
    PASSWORD_FILE="${MARIADB_ROOT_PASSWORD_FILE:-/run/secrets/db_password}"
    if [ ! -f "$PASSWORD_FILE" ]; then
        echo "ERROR: Password file not found at $PASSWORD_FILE"
        exit 1
    fi
    ROOT_PASS=$(cat "$PASSWORD_FILE")
fi

echo "Processing init-data.json..."

# Read users array
USERS_COUNT=$(jq '.users | length' "$CONFIG_FILE")

for ((i=0; i<$USERS_COUNT; i++)); do
    USERNAME=$(jq -r ".users[$i].username" "$CONFIG_FILE")
    PASSWORD=$(jq -r ".users[$i].password" "$CONFIG_FILE")

    echo "Creating user: $USERNAME"

    # Create user if not exists
    mariadb -u root -p"$ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$USERNAME'@'%' IDENTIFIED BY '$PASSWORD';"

    # Process databases for this user
    DBS_COUNT=$(jq ".users[$i].databases | length" "$CONFIG_FILE")
    for ((j=0; j<$DBS_COUNT; j++)); do
        DBNAME=$(jq -r ".users[$i].databases[$j]" "$CONFIG_FILE")
        echo "  Creating database: $DBNAME"
        mariadb -u root -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DBNAME\`;"
        mariadb -u root -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON \`$DBNAME\`.* TO '$USERNAME'@'%';"
    done
done

echo "Flushing privileges..."
mariadb -u root -p"$ROOT_PASS" -e "FLUSH PRIVILEGES;"
echo "Done."
