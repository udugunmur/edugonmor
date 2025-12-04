# {{cookiecutter.project_name}}

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura "Standard Pattern". Cualquier modificación en `docker-compose.yml` debe respetar las siguientes reglas:

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: `{{cookiecutter.project_slug}}_services`
    *   Servicio de Backup: `{{cookiecutter.project_slug}}_backup`
    *   Contenedores: `container_name: {{cookiecutter.project_slug}}_<rol>`
2.  **Nomenclatura de Volúmenes:**
    *   Datos: `{{cookiecutter.project_slug}}_volumen`
    *   Backups: `{{cookiecutter.project_slug}}_backups`
3.  **Configuración:**
    *   Uso obligatorio de archivo `.env`.
    *   Prohibido el uso de Docker Secrets (`secrets:`).
    *   Credenciales inyectadas vía variables de entorno.
4.  **Redes:**
    *   Red dedicada: `{{cookiecutter.network_name}}`

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
