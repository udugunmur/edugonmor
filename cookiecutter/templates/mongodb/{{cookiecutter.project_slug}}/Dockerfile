# MongoDB {{cookiecutter.mongo_version}} - Imagen oficial
# Documentación: https://www.mongodb.com/docs/v{{cookiecutter.mongo_version}}/
FROM mongo:{{cookiecutter.mongo_version}}

# Instalar herramientas adicionales
RUN apt-get update && apt-get install -y \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copiar scripts de inicialización
COPY docker/scripts/init-db/ /docker-entrypoint-initdb.d/

# Copiar configuración personalizada (opcional)
# COPY config/mongod.conf /etc/mongod.conf

# Puerto por defecto de MongoDB
EXPOSE 27017

# El entrypoint por defecto de la imagen oficial se encarga de todo
