# Cookiecutter Templates Collection

Este directorio contiene la colección centralizada de plantillas **Cookiecutter** para el ecosistema Edugonmor.

## 📂 Plantillas Disponibles

Las plantillas se encuentran organizadas dentro del directorio `templates/`:

| Plantilla | Descripción | Ruta |
|-----------|-------------|------|
| **MariaDB** | Plantilla para proyectos de base de datos MariaDB con Docker, Backups y Monitorización. | `templates/mariadb` |
| **MySQL** | Plantilla para proyectos de base de datos MySQL con Docker, Backups y Monitorización. | `templates/mysql` |

## 🚀 Uso

Para iniciar un nuevo proyecto utilizando una de estas plantillas, ejecuta el comando `cookiecutter` apuntando a la ruta específica:

### MariaDB
```bash
cookiecutter ./cookiecutter/templates/mariadb
```

### MySQL
```bash
cookiecutter ./cookiecutter/templates/mysql
```

## 📚 Documentación y Estándares

*   **[Arquitectura de Plantillas](docs/arquitectura_plantilla.md)**: Detalles técnicos sobre cómo funcionan estas plantillas.
*   **[AGENTS.md](AGENTS.md)**: Protocolo Maestro para el desarrollo y mantenimiento de estas plantillas por parte de Agentes de IA.

## 🛠️ Mantenimiento

Para agregar una nueva plantilla:
1.  Crea una nueva carpeta en `templates/<nombre_tecnologia>`.
2.  Asegúrate de incluir `cookiecutter.json` y la estructura `{{cookiecutter.project_slug}}/`.
3.  Sigue los estándares definidos en `AGENTS.md`.

---
**Edugonmor Infrastructure**
