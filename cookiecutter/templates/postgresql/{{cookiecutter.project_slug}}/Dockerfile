# PostgreSQL {{cookiecutter._postgres_version}} - Imagen oficial
# Documentación: https://www.postgresql.org/docs/{{cookiecutter._postgres_version}}/
FROM postgres:{{cookiecutter._postgres_version}}

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
COPY --chmod=755 docker/scripts/init-db/* /docker-entrypoint-initdb.d/

# Establecemos el entrypoint personalizado
ENTRYPOINT ["custom-entrypoint.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
