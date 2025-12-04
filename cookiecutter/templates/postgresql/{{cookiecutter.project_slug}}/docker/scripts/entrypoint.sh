#!/bin/sh
set -e

if command -v docker-entrypoint.sh >/dev/null 2>&1; then
  exec docker-entrypoint.sh "$@"
fi

exec "$@"
