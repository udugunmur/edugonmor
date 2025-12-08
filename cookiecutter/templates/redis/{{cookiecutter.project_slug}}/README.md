# {{cookiecutter._project_name}}

Repositorio de infraestructura para Redis Database.

## 🚀 Inicio Rápido

1.  **Arrancar servicios**:
    ```bash
    docker compose up -d
    ```

## 📂 Estructura
- `docker/`: Configuración de volúmenes y scripts de contenedor.
- `docs/`: Documentación detallada (`guia_de_verificacion.md`).

## 🛡️ Backup
- Los backups se realizan automáticamente en `{{cookiecutter._host_backup_path}}` (configurado en `cookiecutter.json`).
- Política de retención: {{cookiecutter._backup_retention}} días.

## 🔧 Detalles Técnicos
- **Puerto**: {{cookiecutter._redis_port}}
- **Red**: {{cookiecutter._network_name}}
- **Autenticación**: Contraseña habilitada (ver `.env`).
