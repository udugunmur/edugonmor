# Project Initialized

This repository has been initialized following the Master Protocol.

## Structure
- `agent.md`: Master Protocol and Architecture Guidelines.
- `docker/`: Infrastructure configuration.
- `config/`: Application configuration.

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura "Standard Pattern". Cualquier modificación en `docker-compose.yml` debe respetar las siguientes reglas:

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: `proyecto_services`
    *   Servicio de Backup: `proyecto_backup`
    *   Contenedores: `container_name: proyecto_<rol>`
2.  **Nomenclatura de Volúmenes:**
    *   Datos: `proyecto_volumen`
    *   Backups: `proyecto_backups`
3.  **Configuración:**
    *   Uso obligatorio de archivo `.env`.
    *   Prohibido el uso de Docker Secrets (`secrets:`).
    *   Credenciales inyectadas vía variables de entorno.
4.  **Redes:**
    *   Red dedicada: `proyecto_network`
