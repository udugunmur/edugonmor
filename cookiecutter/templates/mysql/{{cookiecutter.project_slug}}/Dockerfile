FROM mysql:latest

# Install jq for JSON processing and tzdata for Timezone
RUN microdnf update && microdnf install -y jq tzdata && microdnf clean all

# Copy custom configuration
COPY config/my.cnf /etc/mysql/conf.d/custom.cnf

# Copy scripts
COPY docker/scripts/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY docker/scripts/sync-db.sh /usr/local/bin/sync-db.sh
COPY docker/scripts/01-init.sh /docker-entrypoint-initdb.d/01-init.sh

# Set permissions
RUN chmod +x /usr/local/bin/healthcheck.sh /usr/local/bin/sync-db.sh /docker-entrypoint-initdb.d/01-init.sh
