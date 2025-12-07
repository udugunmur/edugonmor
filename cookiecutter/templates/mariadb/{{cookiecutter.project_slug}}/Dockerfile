# ============================================================================
# MariaDB {{cookiecutter.mariadb_version}} - Imagen de Servicio
# ============================================================================
# Documentación: https://mariadb.com/docs/server/
# ============================================================================
FROM mariadb:{{cookiecutter.mariadb_version}}

LABEL maintainer="edugonmor"
LABEL description="MariaDB {{cookiecutter.mariadb_version}} Service"
LABEL version="{{cookiecutter.mariadb_version}}"

# Install jq for JSON processing
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Copy custom configuration
COPY config/my.cnf /etc/mysql/conf.d/custom.cnf

# Copy scripts
COPY docker/scripts/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY docker/scripts/sync-db.sh /usr/local/bin/sync-db.sh
COPY docker/scripts/01-init.sh /docker-entrypoint-initdb.d/01-init.sh

RUN chmod +x /usr/local/bin/healthcheck.sh /usr/local/bin/sync-db.sh /docker-entrypoint-initdb.d/01-init.sh
