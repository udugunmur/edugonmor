#!/bin/bash
set -e

# Check if MariaDB is ready
mariadb-admin ping -h localhost -u root --password=$(cat $MARIADB_ROOT_PASSWORD_FILE)
