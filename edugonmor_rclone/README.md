# Sistema de Backups Automatizados con Rclone y Docker

Este proyecto implementa una solución robusta y segura para realizar copias de seguridad automatizadas de volúmenes Docker hacia proveedores de almacenamiento en la nube (Google Drive, S3, etc.), garantizando la encriptación de los datos antes de que salgan del servidor.

## 🚀 Características

*   **Automatización:** Ejecución periódica mediante Cron dentro de un contenedor Alpine ligero.
*   **Seguridad:**
    *   Encriptación lado cliente (Rclone Crypt).
    *   Acceso de **Solo Lectura** al volumen de origen para evitar corrupción de datos.
*   **Sincronización Bidireccional:** Soporte para descargar/sincronizar nubes (ej. OneDrive) a local.
*   **Portabilidad:** Configuración completa mediante Docker Compose.

## 📂 Estructura del Proyecto

```
.
├── docker/
│   ├── config/          # Ubicación para rclone.conf
│   ├── scripts/         # Scripts de backup y entrypoint
│   ├── docker-compose.yml
│   └── Dockerfile
├── docs/
│   ├── instalacion/     # Guía paso a paso de configuración
│   └── operaciones/     # Guías de restauración y mantenimiento
└── README.md
```

## 📏 Convención de Nombres

Para mantener la coherencia en el despliegue de múltiples cuentas y servicios, se utiliza la siguiente nomenclatura estricta en `docker-compose.yml`:

### Servicios
El formato es: `rclone_<proveedor>_<usuario>_[tipo]_service`
*   Ejemplo Local: `rclone_local_backup_service`
*   Ejemplo OneDrive: `rclone_onedrive_edugonmor_service`
*   Ejemplo GDrive: `rclone_gdrive_udugunmur_service`

### Volúmenes
El formato es: `rclone_<proveedor>_<usuario>_[tipo]_volumen`
*   Ejemplo Local: `rclone_local_backup_volumen`
*   Ejemplo OneDrive: `rclone_onedrive_edugonmor_volumen`

Esta convención facilita la identificación rápida de qué contenedor gestiona qué cuenta y qué volumen de datos está asociado.

## 🛠️ Inicio Rápido

1.  **Configura Rclone:** Genera tu archivo `rclone.conf` con un remoto encriptado. Ver [Guía de Instalación](docs/instalacion/setup.md).
2.  **Coloca la configuración:** Copia el archivo a `docker/config/rclone.conf`.
3.  **Despliega:**
    ```bash
    cd docker
    docker-compose up -d
    ```

## 📄 Documentación

*   [Instalación y Configuración (Backup Encriptado)](docs/instalacion/setup.md)
*   [Configuración OneDrive (Sincronización)](docs/instalacion/onedrive.md)
*   [Operaciones y Restauración](docs/operaciones/backup-restore.md)

## 🤖 Agente IA

Este repositorio sigue las directrices definidas en `agent.md`.

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura "Edugonmor Pattern". Cualquier modificación en `docker-compose.yml` debe respetar las siguientes reglas:

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: `edugonmor_<proyecto>_services`
    *   Servicio de Backup: `edugonmor_<proyecto>_backup`
    *   Contenedores: `container_name: edugonmor_<proyecto>_<rol>`
2.  **Nomenclatura de Volúmenes:**
    *   Datos: `edugonmor_<proyecto>_volumen`
    *   Backups: `edugonmor_<proyecto>_backups`
3.  **Configuración:**
    *   Uso obligatorio de archivo `.env`.
    *   Prohibido el uso de Docker Secrets (`secrets:`).
    *   Credenciales inyectadas vía variables de entorno.
4.  **Redes:**
    *   Red dedicada: `edugonmor_<proyecto>_network`
