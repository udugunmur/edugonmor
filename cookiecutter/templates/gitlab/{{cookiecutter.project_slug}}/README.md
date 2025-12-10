# GitLab Server

Repositorio de infraestructura para GitLab Server.

## 🚀 Inicio Rápido

1.  **Arrancar servicios**:
    ```bash
    docker compose up -d
    ```
2.  **Verificar**:
    ```bash
    # Ver estado de los contenedores
    docker compose ps
    ```
3.  **Acceder**:
    *   Web: Ver `GITLAB_HOSTNAME` y puertos en `.env`.
    *   **Credenciales Iniciales**:
        *   Usuario: `root`
        *   Contraseña: Ver `GITLAB_ROOT_PASSWORD` en `.env`.

## 📂 Estructura
- `docker/volumes/`: Persistencia de datos local (config, data, logs).
- `docs/`: Documentación detallada (`guia_de_verificacion.md`).
- `.env`: Variables de entorno para configuración.

## 🛡️ Backup
- Los backups se configuran mediante cron en el contenedor `backup`.
- **Ruta Host**: Ver `HOST_BACKUP_PATH` en `.env`.
- **Retención**: Ver `BACKUP_RETENTION` en `.env`.

## 🔧 Detalles Técnicos
- **Puertos Expuestos**: 
    - HTTP: Ver `GITLAB_HTTP_PORT` en `.env`
    - HTTPS: Ver `GITLAB_HTTPS_PORT` en `.env`
    - SSH: Ver `GITLAB_SSH_PORT` en `.env`
- **Red**: `shared_network`

