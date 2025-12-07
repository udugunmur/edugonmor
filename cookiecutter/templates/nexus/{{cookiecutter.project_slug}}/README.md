# {{cookiecutter._project_name}}

Repositorio de infraestructura para Nexus Repository Manager.

## 🚀 Inicio Rápido

1.  **Arrancar servicios**:
    ```bash
    docker compose up -d
    ```

2.  **Configurar Nexus** (una vez online):
    ```bash
    ./scripts/setup_nexus.sh
    ```

## 📂 Estructura
- `docker/`: Configuración de volúmenes y scripts de contenedor.
- `scripts/`: Scripts de utilidad para el host (setup, push masivo).
- `docs/`: Documentación detallada (`guia_de_verificacion.md`).

## 🛡️ Backup
- Los backups se realizan automáticamente en `./backups/nexus` (configurado en `cookiecutter.json`).
- Ver `AGENTS.md` para política de retención.

## 🔧 Herramientas
- `scripts/push_all_images.sh`: Escanea directorios hermanos y sube sus imágenes Docker a este registro.
