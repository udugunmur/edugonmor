# Arquitectura de Plantillas (Multi-Template)

Este documento detalla la arquitectura del repositorio de plantillas Cookiecutter. A diferencia de una plantilla única, este directorio actúa como un **contenedor centralizado** para múltiples plantillas de proyectos estandarizados.

## 1. Estructura del Repositorio

El directorio `cookiecutter/` no es una plantilla en sí misma, sino una colección organizada:

```text
cookiecutter/
├── AGENTS.md                   # Normas y Protocolos para la IA (Global)
├── docs/                       # Documentación Transversal
└── templates/                  # 📂 Colección de Plantillas
    ├── mariadb/                # Plantilla para MariaDB
    │   ├── cookiecutter.json
    │   └── {{cookiecutter.project_slug}}/
    └── mysql/                  # Plantilla para MySQL
        ├── cookiecutter.json
        └── {{cookiecutter.project_slug}}/
```

## 2. Funcionamiento de las Plantillas Individuales

Cada subdirectorio dentro de `templates/` (ej: `mariadb`, `mysql`) funciona como una plantilla Cookiecutter independiente y completa.

### Componentes de cada Plantilla:
*   **`cookiecutter.json`**: Archivo de configuración específico para esa tecnología.
*   **`{{cookiecutter.project_slug}}/`**: El "molde" dinámico que se generará.
*   **`hooks/`**: Scripts de pre/post generación específicos.

## 3. Motor de Renderizado (Jinja2)

Todas las plantillas utilizan **Jinja2** para la sustitución dinámica.

### Sintaxis Básica
*   `{{ variable }}`: Imprime el valor de una variable definida en el `cookiecutter.json` de la plantilla específica.
*   `{% if variable %}`: Lógica condicional.

### Ejemplo de Uso

Para generar un proyecto usando una de estas plantillas, se debe apuntar a la subcarpeta específica y especificar el directorio de salida:

```bash
# Para generar un proyecto MariaDB
cookiecutter ./cookiecutter/templates/mariadb -o output

# Para generar un proyecto MySQL
cookiecutter ./cookiecutter/templates/mysql -o output
```

## 4. Estándares Compartidos

Aunque cada plantilla es independiente, todas deben adherirse a los estándares definidos en `AGENTS.md` y `docs/`:

*   **Estructura de Carpetas**: `src/`, `tests/`, `docs/`, `docker/`.
*   **Archivos Obligatorios**: `README.md`, `.env.example`.
*   **Nomenclatura**: Uso de `project_slug` para nombres de carpetas y archivos.

---
**Generado bajo Protocolo Maestro - Edugonmor**
