# Guía de Instalación y Configuración

## 1. Prerrequisitos

*   Docker y Docker Compose instalados.
*   Un volumen de Docker o directorio local para respaldar (ej. `rclone_local_backup_volumen`).
*   Acceso a un proveedor de almacenamiento en la nube (Google Drive, AWS S3, Dropbox, etc.).

## 2. Generar Configuración de Rclone (Encriptada)

Para cumplir con el requisito de seguridad, los datos deben encriptarse antes de subir. Usaremos `rclone crypt`.

### Paso 2.1: Configurar remoto base
Ejecuta rclone en tu máquina local (o en un contenedor temporal) para configurar el acceso a la nube:

```bash
rclone config
# Selecciona 'n' para nuevo remoto.
# Elige tu proveedor (ej. 'drive' para Google Drive).
# Sigue los pasos de autenticación.
# Nómbralo, por ejemplo: 'gdrive'
```

### Paso 2.2: Configurar capa de encriptación (Crypt)
Ahora crea un segundo remoto que use el primero:

```bash
rclone config
# Selecciona 'n' para nuevo remoto.
# Nómbralo: 'secure-remote' (este nombre debe coincidir con la variable BACKUP_DEST en docker-compose.yml).
# Tipo de almacenamiento: Selecciona 'crypt'.
# Remote to encrypt: Pon el nombre del anterior + ruta. Ej: 'gdrive:backups_encriptados'
# Configura las contraseñas (¡GUÁRDALAS BIEN! Sin ellas pierdes los datos).
```

### Paso 2.3: Guardar configuración
Copia el archivo generado (usualmente en `~/.config/rclone/rclone.conf`) a la carpeta del proyecto:

```bash
cp ~/.config/rclone/rclone.conf ./docker/config/rclone.conf
```

## 3. Despliegue

1.  Navega a la carpeta `docker`:
    ```bash
    cd docker
    ```
2.  Levanta el servicio:
    ```bash
    docker-compose up -d --build
    ```
3.  Verifica los logs:
    ```bash
    docker logs -f rclone_backup_service
    ```
