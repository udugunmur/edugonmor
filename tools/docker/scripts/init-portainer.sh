#!/bin/bash
#
# init-portainer.sh - Script de inicialización de Portainer
#

set -e

echo "Inicializando Portainer..."

mkdir -p /data/compose
mkdir -p /data/tls

if [ -S /var/run/docker.sock ]; then
    echo "[OK] Docker socket accesible"
else
    echo "[ERROR] Docker socket no encontrado"
    exit 1
fi

echo "Inicialización completada."
