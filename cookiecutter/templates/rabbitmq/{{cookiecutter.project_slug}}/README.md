# {{cookiecutter._project_name}}

Repositorio de infraestructura para RabbitMQ Service.

## 🚀 Inicio Rápido

1.  **Arrancar servicios**:
    ```bash
    docker compose up -d
    ```

2.  **Verificar estado**:
    ```bash
    ./scripts/setup_rabbitmq.sh
    ```

## 📂 Estructura
- `docker/`: Configuración de volúmenes y scripts de contenedor.
- `scripts/`: Scripts de utilidad para el host (setup, verificaciones).
- `docs/`: Documentación detallada (`guia_de_verificacion.md`).
- `src/`: Código fuente de la aplicación (si aplica).
- `tests/`: Tests de integración/unitarios.

## 🛡️ Backup
- Los backups se realizan automáticamente (si se configura) en `./backups/rabbitmq` (configurado en `cookiecutter.json`).

## 🔧 Herramientas
- `scripts/setup_rabbitmq.sh`: Verifica la disponibilidad del servicio y realiza configuraciones iniciales si es necesario.
