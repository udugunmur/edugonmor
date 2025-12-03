# Guía de Ejecución Paso a Paso

Este documento describe el procedimiento estándar para utilizar la fábrica de proyectos `cookiecutter` bajo el entorno orquestado de **Edugonmor**.

## 📋 Prerrequisitos

Antes de comenzar, asegúrate de tener instalado en tu sistema host:
*   **VS Code**
*   **Docker Desktop** (o Docker Engine)
*   Extensión **Dev Containers** para VS Code

## 🚀 Flujo de Trabajo Estándar

Sigue estos pasos secuenciales para generar un nuevo proyecto limpio.

### Paso 1: Acceso al Entorno de Trabajo
Abre la carpeta del proyecto en VS Code. El editor detectará la configuración `.devcontainer` y te sugerirá reabrir en contenedor.

Si no lo hace, abre la paleta de comandos (`Ctrl+Shift+P`) y selecciona:
> **Dev Containers: Reopen in Container**

*Esto construirá el entorno y te dejará en una terminal lista para usar.*

### Paso 2: Generación del Proyecto
Una vez dentro del contenedor, ejecuta el comando maestro para iniciar el asistente interactivo.

**IMPORTANTE:** Siempre debes especificar el directorio de salida como `output/`.

```bash
cookiecutter templates/<nombre_plantilla> -o output
```

Ejemplo para MariaDB:
```bash
cookiecutter templates/mariadb -o output
```

El sistema te solicitará los siguientes datos (definidos en `cookiecutter.json`):
1.  **project_name**: Nombre legible del proyecto (ej. "Mi Nuevo Servicio").
2.  **project_slug**: Identificador técnico (ej. "mi_nuevo_servicio"). *Debe ser válido para carpetas.*
3.  **author_name**: Tu nombre o el de la organización.
4.  **open_source_license**: Selecciona la licencia deseada.

### Paso 3: Finalización
Una vez completado el asistente, verás que la carpeta se ha creado en tu explorador de archivos.

## 🧪 Comandos de Utilidad

### Ejecutar Tests de la Plantilla
Para asegurarte de que la plantilla en sí misma funciona correctamente antes de usarla:

```bash
pytest
```
Esto ejecutará `pytest` sobre la carpeta `tests/` para validar la lógica de generación.

---
**Generado bajo Protocolo Maestro - Edugonmor**
