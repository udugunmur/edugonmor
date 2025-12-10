# GitLab Template

Template para desplegar GitLab CE usando Docker y Docker Compose, siguiendo el patrón Edugonmor.

## Uso

Este template está diseñado para ser usado con el generador de proyectos `cookiecutter`.

Variables:
- `project_name`: Nombre del proyecto.
- `project_slug`: Identificador único (usado en nombres de servicios y volúmenes).
- `domain_name`: Dominio donde se servirá GitLab.
- `gitlab_http_port`: Puerto host para HTTP.
- `gitlab_https_port`: Puerto host para HTTPS.
- `gitlab_ssh_port`: Puerto host para SSH.
- `gitlab_version`: Versión de la imagen Docker de GitLab CE.
- `gitlab_root_password`: Contraseña inicial para el usuario root.
- `nexus_registry`: Registry de Docker predeterminado.
- `backup_cron_schedule`: Horario Cron para backups.
- `backup_retention`: Retención de backups en días.

