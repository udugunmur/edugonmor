#!/bin/sh
set -e

# Variables de entorno según FVO PostgreSQL
USER_NAME="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-postgres}"

if pg_isready -U "$USER_NAME" -d "$DB_NAME" >/dev/null 2>&1; then
  exit 0
fi

exit 1
