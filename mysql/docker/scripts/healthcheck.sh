#!/bin/bash
set -e

# Check if MySQL is ready
mysqladmin ping -h localhost -u root --password=$(cat $MYSQL_ROOT_PASSWORD_FILE)
