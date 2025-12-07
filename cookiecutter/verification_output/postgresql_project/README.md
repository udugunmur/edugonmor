# PostgreSQL Project

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura "Standard Pattern". Cualquier modificación en `docker-compose.yml` debe respetar las siguientes reglas:

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: `postgresql_project_services`
    *   Servicio de Backup: `postgresql_project_backup`
    *   Contenedores: `container_name: postgresql_project_<rol>`
2.  **Nomenclatura de Volúmenes:**
    *   Datos: `postgresql_project_volumen`
    *   Backups: `postgresql_project_backups`
3.  **Configuración:**
    *   Uso obligatorio de archivo `.env`.
    *   Prohibido el uso de Docker Secrets (`secrets:`).
    *   Credenciales inyectadas vía variables de entorno.
4.  **Redes:**
    *   Red dedicada: `shared_network`

## Comandos Rápidos

### Iniciar
```bash
docker-compose up -d
```

### Ver Logs
```bash
docker-compose logs -f
```

### Detener
```bash
docker-compose down
```
