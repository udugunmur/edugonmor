# Configuración de OneDrive

Para sincronizar tu cuenta de OneDrive (`edugonmor@outlook.com`), necesitas autorizar a Rclone para acceder a tus archivos.

## Paso 1: Obtener el Token de Acceso

Como Rclone se ejecutará en un servidor (headless), necesitas generar el token en tu ordenador personal (donde tengas navegador web).

1.  Descarga Rclone en tu PC (Windows/Mac/Linux).
2.  Abre una terminal y ejecuta:
    ```bash
    rclone authorize "onedrive"
    ```
3.  Se abrirá una ventana del navegador para iniciar sesión en Microsoft. Usa tu cuenta `edugonmor@outlook.com`.
4.  Acepta los permisos.
5.  Vuelve a la terminal. Rclone te mostrará un código JSON largo que empieza por `{"access_token":...`. **Copia todo ese bloque JSON.**

## Paso 2: Configurar el Servidor

1.  En tu servidor, edita el archivo `docker/config/rclone.conf`.
2.  Añade la siguiente sección al final del archivo:

```ini
[onedrive-edugonmor]
type = onedrive
token = PEGA_AQUI_EL_JSON_QUE_COPIASTE
drive_id = PEGA_AQUI_EL_DRIVE_ID
drive_type = personal
```

> **Nota:** Asegúrate de que el nombre entre corchetes sea exactamente `[onedrive-edugonmor]`, ya que es el que usa el `docker-compose.yml`.  
> Si usas varias cuentas, repite el bloque cambiando el nombre del remoto: `[onedrive_backup]`, `[onedrive_data]`, `[onedrive_media]`, `[onedrive_business]`.

## Paso 3: Desplegar

Una vez guardado el archivo `rclone.conf`:

```bash
cd docker
docker-compose up -d rclone_onedrive_service
```

El contenedor comenzará a descargar tu OneDrive en `/mnt/disk2/rclone/onedrive/edugonmor`.
