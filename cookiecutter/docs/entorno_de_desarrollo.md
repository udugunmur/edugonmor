# Configuración del Entorno de Desarrollo (.devcontainer)

Este documento detalla la arquitectura del entorno de desarrollo contenedorizado utilizado en este proyecto, basado en la especificación **Dev Containers** de Microsoft.

## 🎯 Objetivo
Garantizar un entorno de desarrollo **reproducible, estandarizado y listo para usar** (Zero-Config) para cualquier miembro del equipo, eliminando discrepancias entre sistemas operativos locales.

## 🏗️ Arquitectura

### Imagen Base
*   **Imagen:** `mcr.microsoft.com/devcontainers/python:3.12`
*   **Proveedor:** Microsoft
*   **Características:**
    *   Basada en Debian.
    *   Incluye herramientas comunes de desarrollo (`git`, `zsh`, `curl`, `wget`).
    *   Optimizada para integración con VS Code.

### Herramientas Pre-Instaladas
El entorno se aprovisiona automáticamente con las siguientes herramientas críticas:

1.  **Python 3.12**: Runtime principal.
2.  **Cookiecutter**: Motor de generación de plantillas.
3.  **Docker-in-Docker (DinD)**: Permite ejecutar comandos de Docker *dentro* del contenedor de desarrollo (necesario para probar los proyectos generados).
4.  **Make**: Herramienta de construcción (si se requiere en los proyectos generados).

### Extensiones de VS Code (DX)
Se instalan automáticamente las siguientes extensiones:

*   `ms-python.python`: Soporte para Python.
*   `ms-azuretools.vscode-docker`: Gestión de contenedores.
*   `samuelcolvin.jinjahtml`: Resaltado de sintaxis para plantillas Jinja2.
*   `redhat.vscode-yaml`: Validación de archivos YAML.

## 🚀 Guía de Uso Paso a Paso

### 1. Iniciar el Entorno
1.  Abre la carpeta `cookiecutter` en VS Code.
2.  Abre la paleta de comandos (`Ctrl+Shift+P` / `Cmd+Shift+P`).
3.  Escribe y selecciona: **Dev Containers: Reopen in Container**.
4.  Espera a que el contenedor se construya y configure (la primera vez puede tardar unos minutos).

### 2. Generar un Proyecto
Una vez dentro del contenedor (verás "Dev Container: Cookiecutter Dev" en la esquina inferior izquierda), usa la terminal integrada para generar proyectos.

**Para MariaDB:**
```bash
cookiecutter templates/mariadb
```

**Para MySQL:**
```bash
cookiecutter templates/mysql
```

Sigue las instrucciones interactivas en la terminal para configurar tu proyecto.

### 3. Probar el Proyecto Generado
Dado que el entorno tiene **Docker-in-Docker**, puedes levantar y probar el proyecto generado inmediatamente sin salir de VS Code.

1.  Entra en la carpeta del proyecto generado:
    ```bash
    cd <nombre_de_tu_proyecto>
    ```
2.  Levanta los servicios:
    ```bash
    docker-compose up -d
    ```
3.  Verifica que los contenedores estén corriendo:
    ```bash
    docker ps
    ```

---
**Documentado bajo Protocolo Maestro - Edugonmor**
