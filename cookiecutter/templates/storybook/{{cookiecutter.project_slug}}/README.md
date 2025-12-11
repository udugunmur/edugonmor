# Storybook Project

This repository has been initialized following the Master Protocol.

## Structure
- `agent.md`: Master Protocol and Architecture Guidelines.
- `docker/`: Infrastructure configuration.
- `config/`: Application configuration.

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura "Standard Pattern". Cualquier modificación en `docker-compose.yml` debe respetar las siguientes reglas:

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: Definido en `.env`
    *   Servicio de Backup: `${CONTAINER_NAME}_backup`
    *   Contenedores: `container_name: ${CONTAINER_NAME}`
2.  **Nomenclatura de Volúmenes:**
    *   Datos: `${CONTAINER_NAME}_volumen`
    *   Backups: `${CONTAINER_NAME}_backups`
3.  **Configuración:**
    *   Uso obligatorio de archivo `.env`.
    *   Prohibido el uso de Docker Secrets (`secrets:`).
    *   Credenciales inyectadas vía variables de entorno.
4.  **Redes:**
    *   Red dedicada: Definida en `.env` (`NETWORK_NAME`)
