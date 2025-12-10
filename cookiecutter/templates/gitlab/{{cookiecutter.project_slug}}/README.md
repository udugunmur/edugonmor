# {{cookiecutter.project_name}}

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
    *   Web: `http://{{cookiecutter.domain_name}}:{{cookiecutter.gitlab_http_port}}` (o vía proxy si está configurado para puerto 80/443).
    *   **Credenciales Iniciales**:
        *   Usuario: `root`
        *   Contraseña: Ver `GITLAB_ROOT_PASSWORD` en `.env`.

## 📂 Estructura
- `docker/volumes/`: Persistencia de datos local (config, data, logs).
- `docs/`: Documentación detallada (`guia_de_verificacion.md`).
- `.env`: Variables de entorno para configuración.

## 🛡️ Backup
- Los backups se configuran mediante cron en el contenedor `backup`.
- **Ruta Host**: `{{cookiecutter.host_backup_path}}`
- **Retención**: {{cookiecutter.backup_retention}} días (configuración prevista).

## 🔧 Detalles Técnicos
- **Puertos Expuestos**: 
    - HTTP: {{cookiecutter.gitlab_http_port}}
    - HTTPS: {{cookiecutter.gitlab_https_port}}
    - SSH: {{cookiecutter.gitlab_ssh_port}}
- **Red**: `shared_network`

