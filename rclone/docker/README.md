# Docker - Rclone Backup Service

Esta carpeta contiene la configuración Docker para el servicio de backups automatizados con Rclone.

## 📁 Estructura de Directorios

```
docker/
├── README.md                    # Este archivo
├── docker-compose.yml           # Orquestación del servicio de backup
├── Dockerfile                   # Imagen Alpine con Rclone y Cron
├── .dockerignore                # Archivos excluidos del build
├── config/                      # Configuración de Rclone (montado)
│   └── rclone.conf              # Archivo de configuración (NO INCLUIDO EN GIT)
└── scripts/                     # Scripts del contenedor
    ├── entrypoint.sh            # Configuración de Cron al inicio
    └── backup.sh                # Lógica de sincronización
```

## 📏 Nomenclatura de Servicios y Volúmenes

Para mantener la consistencia en entornos con múltiples cuentas, se utiliza la siguiente convención en `docker-compose.yml`:

*   **Servicios:** `rclone_<proveedor>_<usuario>_[tipo]_service`
    *   Ej: `rclone_onedrive_service`
*   **Volúmenes:** `rclone_<proveedor>_<usuario>_[tipo]_volumen`
    *   Ej: `rclone_onedrive_volumen`

## 🐳 Uso

### Construcción de la imagen

```bash
cd docker
docker-compose build
```

### Iniciar servicio

```bash
cd docker
docker-compose up -d
```

### Verificar logs

```bash
# Ejemplo para el servicio local
docker logs -f rclone_local_backup_service

# Ejemplo para un servicio de OneDrive
docker logs -f rclone_onedrive_service
```

## 🔐 Seguridad

*   El contenedor se ejecuta con acceso de **Solo Lectura** al volumen de datos.
*   La configuración de Rclone (`rclone.conf`) debe contener remotos encriptados (`type = crypt`).
*   No incluyas `rclone.conf` en el control de versiones.

## �� Referencias

- **Rclone Docker**: https://rclone.org/install/#docker
- **Alpine Linux**: https://alpinelinux.org/
