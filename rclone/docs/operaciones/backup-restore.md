# Operaciones de Backup y Restauración

## Estrategia de Automatización

Se ha optado por utilizar un **contenedor dedicado con Cron interno** (basado en Alpine Linux).

**¿Por qué esta opción?**
*   **Aislamiento:** El proceso de backup y sus dependencias (rclone, certificados) no ensucian el sistema host.
*   **Portabilidad:** Todo el sistema de backup se define en código (Dockerfile + docker-compose). Puedes moverlo a otro servidor y funcionará igual.
*   **Seguridad:** El contenedor tiene acceso de **Solo Lectura (:ro)** a los datos sensibles, impidiendo que un error en el script o un malware borre los datos originales.

## Ejecución Manual del Backup

Si necesitas forzar un backup fuera del horario programado:

```bash
# Para el backup local
docker exec rclone_local_backup_service /scripts/backup.sh

# Para una sincronización de OneDrive
docker exec rclone_onedrive_service /scripts/backup.sh
```

## Restauración de Datos (Disaster Recovery)

En caso de pérdida de datos, sigue estos pasos para restaurar desde la nube.

**ADVERTENCIA:** La restauración sobrescribirá los datos en el destino si usas `sync`. Ten precaución.

1.  Detén los contenedores que usen el volumen afectado.
2.  Crea un contenedor temporal para restaurar (ya que el de backup suele ser de solo lectura o para evitar conflictos):

```bash
# Ejemplo restaurando el volumen local
docker run --rm -it \
    -v rclone_local_backup_volumen:/data \
    -v $(pwd)/config/rclone.conf:/config/rclone.conf:ro \
    alpine:latest sh
```

3.  Dentro del contenedor temporal, instala rclone y restaura:

```bash
apk add rclone
# Restaurar desde el remoto encriptado hacia el volumen
rclone copy secure-remote:backups/docker-volumes /data --config /config/rclone.conf -v
```

4.  Verifica los datos y reinicia tus servicios.
