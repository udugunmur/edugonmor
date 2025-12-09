# {{cookiecutter._project_name}}

Repositorio de infraestructura para Penpot (Open Source Design & Prototyping Tool).

## 🚀 Inicio Rápido

1.  **Arrancar servicios**:
    ```bash
    docker compose up -d
    ```

2.  **Verificar estado**:
    ```bash
    docker compose ps
    ```

## 📂 Estructura
- `docker/`: Configuración de volúmenes persistentes.
- `docs/`: Documentación detallada (`guia_de_verificacion.md`).

## 🛡️ Backup
- Los backups de assets se realizan automáticamente en `{{cookiecutter._host_backup_path}}` (configurado en `cookiecutter.json`).
- Script de backup en contenedor `penpot_backup`.

## 🔧 Configuración
- Variables de entorno en `.env`.
- Base de datos y Redis externos configurados vía variables de entorno.
