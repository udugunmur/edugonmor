# {{cookiecutter.project_name}}

GitLab Server Docker deployment generated via Cookiecutter.

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura definido.

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: `{{cookiecutter.project_slug}}_gitlab_services`
    *   Servicio de Backup: `{{cookiecutter.project_slug}}_backup`
2.  **Volúmenes:**
    *   Config: `{{cookiecutter.project_slug}}_config_volumen`
    *   Logs: `{{cookiecutter.project_slug}}_logs_volumen`
    *   Data: `{{cookiecutter.project_slug}}_data_volumen`
    *   Backups: `{{cookiecutter.project_slug}}_backups` (Mapeado a ruta host de rclone)
3.  **Redes:**
    *   `shared_network`

## Getting Started

1.  Configurar `.env` (si es necesario).
2.  Levantar servicios:
    ```bash
    make up
    ```
3.  Acceder a GitLab en `http://{{cookiecutter.domain_name}}:{{cookiecutter.gitlab_http_port}}`.

## Backups

Los backups se almacenan en el volumen `{{cookiecutter.project_slug}}_backups` que está mapeado al host.
