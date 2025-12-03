# Flujo de Ejecución del Sistema Cookiecutter

Este documento detalla la arquitectura de ejecución, el ciclo de vida de los datos y la orquestación de infraestructura del sistema de plantillas `cookiecutter` bajo el patrón **Edugonmor**.

## 1. Diagrama de Flujo (Ciclo de Vida)

El siguiente diagrama ilustra la secuencia estricta desde la invocación del comando hasta la generación del artefacto final.

```mermaid
graph TD
    A[Inicio: cookiecutter templates/mariadb -o output] -->|Lee Configuración| B(cookiecutter.json)
    B --> C{Validación Previa}
    C -->|hooks/pre_gen_project.py| D[Valida project_slug y output dir]
    D -- Error --> E[Abortar: Exit 1]
    D -- OK --> F[Motor Jinja2]
    F -->|Renderiza| G[Carpeta: output/{{cookiecutter.project_slug}}]
    G --> H{Post-Procesamiento}
    H -->|hooks/post_gen_project.py| I[Limpieza Condicional]
    I --> J[Inicialización Git]
    J --> K[Fin: Proyecto Generado]
```

## 2. Orquestación de Infraestructura

El sistema no se ejecuta en el host directamente, sino a través de un entorno contenedorizado para garantizar reproducibilidad.

### Componentes Clave
*   **Docker**: Provee un entorno Python limpio con [`cookiecutter`](cookiecutter ) y dependencias instaladas.
*   **Volúmenes**: Se monta el directorio actual para que el output se escriba en el sistema de archivos del host (`/home/edugonmor/repos/...`).

## 3. Detalle de Fases

### Fase A: Entrada de Datos (`cookiecutter.json`)
Define el esquema de variables. No solo solicita datos, sino que establece valores por defecto inteligentes.
*   **Inputs**: `project_name`, `author_name`, `open_source_license`.
*   **Derivados**: `project_slug` (usualmente derivado del nombre).

### Fase B: Hooks de Validación (`pre_gen_project.py`)
Garantiza la integridad antes de escribir en disco.
*   **Regla Maestra**: El `project_slug` debe ser compatible con nombres de paquetes Python y directorios Linux (regex: `^[a-z0-9_]+$`).

### Fase C: Renderizado (Template)
El motor Jinja2 recorre recursivamente el directorio `{{cookiecutter.project_slug}}`.
*   **Archivos**: Reemplaza `{{ variable }}` dentro de los archivos.
*   **Directorios**: Renombra carpetas dinámicamente.

### Fase D: Finalización (`post_gen_project.py`)
Ejecuta lógica condicional compleja que Jinja2 no puede manejar solo.
*   **Limpieza**: Si `use_docker` es `n`, elimina `Dockerfile` y `docker-compose.yml` generados.
*   **Git**: Inicializa el repositorio y realiza el primer commit si está configurado.

---
**Generado bajo Protocolo Maestro - Edugonmor**
