# Cookiecutter Project

Este repositorio contiene una plantilla de proyecto basada en **Cookiecutter**, siguiendo los estándares de infraestructura definidos.

## Structure
- `AGENTS.md`: Master Protocol and Architecture Guidelines.
- `docker/`: Infrastructure configuration.
- `cookiecutter.json`: Configuration for the template.
- `{{cookiecutter.project_slug}}/`: The project template itself.

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura definido. Cualquier modificación en `docker-compose.yml` debe respetar las siguientes reglas:

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: `cookiecutter_services`
    *   Servicio de Backup: `cookiecutter_backup` (si aplica)
    *   Contenedores: `container_name: cookiecutter_<rol>`
2.  **Configuración:**
    *   Uso obligatorio de archivo `.env`.
    *   Credenciales inyectadas vía variables de entorno.
3.  **Redes:**
    *   Red compartida: `shared_network`

## Uso

### Requisitos
- Docker
- Docker Compose

### Generar un Proyecto
Para generar un nuevo proyecto usando esta plantilla dentro del entorno contenedorizado:

```bash
make run
# Dentro del contenedor:
cookiecutter .
```

O para ejecutar pruebas sobre la plantilla:

```bash
make test
```
