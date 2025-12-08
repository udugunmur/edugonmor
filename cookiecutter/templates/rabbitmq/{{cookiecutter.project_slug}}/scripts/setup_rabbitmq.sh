#!/bin/bash

# Setup script for {{cookiecutter.project_slug}}
# This script verifies that the RabbitMQ service is up and accessible.

USER="{{cookiecutter._rabbitmq_user}}"
PASS="{{cookiecutter._rabbitmq_password}}"
PORT="{{cookiecutter._rabbitmq_management_port}}"
HOST="{{cookiecutter._rabbitmq_host}}"

echo "Checking RabbitMQ connectivity..."

if command -v curl >/dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "$USER:$PASS" http://$HOST:$PORT/api/overview)
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo "✅ RabbitMQ is ready and accessible."
    else
        echo "❌ RabbitMQ responded with HTTP code: $HTTP_CODE"
        echo "Please check logs: docker compose logs {{cookiecutter.project_slug}}"
        exit 1
    fi
else
    echo "⚠️ curl is not installed, cannot verify via API."
fi
