#!/bin/bash
set -e

CONFIG_FILE="/etc/mysql/custom/init-data.json"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 0
fi

echo "Processing init-data.json..."

# Read users array
USERS_COUNT=$(jq '.users | length' "$CONFIG_FILE")

for ((i=0; i<$USERS_COUNT; i++)); do
    USERNAME=$(jq -r ".users[$i].username" "$CONFIG_FILE")
    PASSWORD=$(jq -r ".users[$i].password" "$CONFIG_FILE")
    
    echo "Creating user: $USERNAME"
    
    PASSWORD_FILE="${MYSQL_ROOT_PASSWORD_FILE:-/run/secrets/db_password}"

    if [ ! -f "$PASSWORD_FILE" ]; then
        echo "ERROR: Password file not found at $PASSWORD_FILE"
        exit 1
    fi

    # Create user if not exists
    mysql -u root -p"$(cat $PASSWORD_FILE)" -e "CREATE USER IF NOT EXISTS '$USERNAME'@'%' IDENTIFIED BY '$PASSWORD';"

    # Process databases for this user
    DBS_COUNT=$(jq ".users[$i].databases | length" "$CONFIG_FILE")
    for ((j=0; j<$DBS_COUNT; j++)); do
        DBNAME=$(jq -r ".users[$i].databases[$j]" "$CONFIG_FILE")
        echo "  Creating database: $DBNAME"
        mysql -u root -p"$(cat $PASSWORD_FILE)" -e "CREATE DATABASE IF NOT EXISTS \`$DBNAME\`;"
        mysql -u root -p"$(cat $PASSWORD_FILE)" -e "GRANT ALL PRIVILEGES ON \`$DBNAME\`.* TO '$USERNAME'@'%';"
    done
done

echo "Flushing privileges..."
mysql -u root -p"$(cat $PASSWORD_FILE)" -e "FLUSH PRIVILEGES;"
echo "Done."
