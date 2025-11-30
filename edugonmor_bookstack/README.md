# edugonmor_bookstack
BookStack Docker deployment

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
