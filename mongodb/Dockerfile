# MongoDB 6.0 - Imagen oficial
# Documentación: https://hub.docker.com/_/mongo
FROM mongo:6.0

# Instalar jq y gettext-base (para envsubst) si fuera necesario
RUN apt-get update && apt-get install -y jq gettext-base && rm -rf /var/lib/apt/lists/*

# Copiamos configuración personalizada (si existiera, por ahora placeholder o comentado)
# COPY config/mongod.conf /etc/mongo/mongod.conf

# Copiamos el archivo de configuración JSON
COPY config/init-data.json /etc/mongo-custom/init-data.json

# Copiamos scripts de inicialización a /docker-entrypoint-initdb.d/
# Estos se ejecutan automáticamente en la primera inicialización
COPY docker/scripts/init-db/* /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/*.sh

# Variables de entorno adicionales
ENV TZ=UTC

# Entrypoint por defecto de la imagen oficial (ajustar si creamos custom entrypoint)
# ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]

# Healthcheck básico (ajustar si creamos script)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
