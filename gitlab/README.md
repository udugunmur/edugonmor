# gitlab
GitLab Server Docker deployment

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura definido. Cualquier modificación en `docker-compose.yml` debe respetar las siguientes reglas:

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: `<proyecto>_services`
    *   Servicio de Backup: `<proyecto>_backup`
    *   Contenedores: `container_name: <proyecto>_<rol>`
2.  **Nomenclatura de Volúmenes:**
    *   Datos: `<proyecto>_volumen`
    *   Backups: `<proyecto>_backups`
3.  **Configuración:**
    *   Uso obligatorio de archivo `.env`.
    *   Prohibido el uso de Docker Secrets (`secrets:`).
    *   Credenciales inyectadas vía variables de entorno.
4.  **Redes:**
    *   Red compartida: `shared_network`
