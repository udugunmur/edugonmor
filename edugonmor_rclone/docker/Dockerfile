FROM alpine:latest

# Instalar dependencias: rclone para backups, bash para scripts, ca-certificates para HTTPS, tzdata para zona horaria
RUN apk add --no-cache \
    rclone \
    bash \
    ca-certificates \
    tzdata

# Crear directorios de trabajo
RUN mkdir -p /config /data /logs /scripts

# Copiar scripts de automatización
COPY scripts/entrypoint.sh /scripts/entrypoint.sh
COPY scripts/backup.sh /scripts/backup.sh

# Asegurar permisos de ejecución
RUN chmod +x /scripts/entrypoint.sh /scripts/backup.sh

# Variables de entorno configurables
ENV CRON_SCHEDULE="0 3 * * *" \
    RCLONE_CONFIG=/config/rclone.conf \
    BACKUP_SOURCE=/data \
    BACKUP_DEST=remote:backup \
    CHECK_URL=""

# Punto de entrada
ENTRYPOINT ["/scripts/entrypoint.sh"]
