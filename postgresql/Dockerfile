# PostgreSQL 16 - Imagen oficial
# Documentación: https://www.postgresql.org/docs/16/
FROM postgres:16

# Instalar jq y gettext-base (para envsubst) para procesar archivos JSON y variables
RUN apt-get update && apt-get install -y jq gettext-base && rm -rf /var/lib/apt/lists/*

# Copiamos configuración personalizada desde la carpeta config/
COPY config/postgresql.conf /etc/postgresql/postgresql.conf

# Copiamos el archivo de configuración JSON
COPY config/init-data.json /etc/postgresql-custom/init-data.json

# Copiamos scripts desde la carpeta docker/scripts/ del repositorio
COPY --chmod=755 docker/scripts/entrypoint.sh /usr/local/bin/custom-entrypoint.sh
COPY --chmod=755 docker/scripts/healthcheck.sh /usr/local/bin/custom-healthcheck.sh
COPY --chmod=755 docker/scripts/sync-db.sh /usr/local/bin/sync-db-config

# Copiamos scripts de inicialización a /docker-entrypoint-initdb.d/
# Estos se ejecutan automáticamente en la primera inicialización
COPY docker/scripts/init-db/* /docker-entrypoint-initdb.d/

# Variables de entorno adicionales
ENV TZ=UTC

# Usamos el entrypoint personalizado que delega al oficial de postgres
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]

# Healthcheck personalizado
HEALTHCHECK --interval=60s --timeout=10s --start-period=180s --retries=3 CMD ["/usr/local/bin/custom-healthcheck.sh"]
