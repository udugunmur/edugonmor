# Guía de Instalación en Máquina Física

Esta guía detalla los pasos para configurar el entorno de ejecución de `cookiecutter` directamente sobre el sistema operativo anfitrión (Linux), replicando las capacidades del devcontainer pero utilizando herramientas modernas de gestión de versiones.

## Prerrequisitos

Asegúrate de tener acceso a una terminal y permisos de `sudo` para ciertas configuraciones iniciales.

### Herramientas Base
*   **Git**: Para clonar el repositorio.
*   **Docker & Docker Compose**: Para ejecutar los servicios generados y pruebas.
*   **uv**: Gestor de paquetes y herramientas de Python (extremadamente rápido y aislado).
*   **nvm**: Gestor de versiones de Node.js.

## Pasos de Instalación

### 1. Preparación del Sistema y Docker

Asegúrate de que Docker está instalado y tu usuario pertenece al grupo `docker`. Esto permite ejecutar comandos de docker sin `sudo`, igual que en el devcontainer.

```bash
# Si docker no está instalado, sigue la doc oficial o usa los paquetes de tu distro.
# Añadir usuario al grupo docker (requiere reiniciar sesión para aplicar cambios):
sudo usermod -aG docker $USER
newgrp docker
```

Verificación:
```bash
docker ps
# Debería mostrar la lista de contenedores (o vacía) sin pedir password
```

### 2. Configuración de Python con `uv`

Usaremos `uv` para gestionar la herramienta `cookiecutter` de forma aislada, evitando ensuciar el Python del sistema.

1.  **Instalar `uv`** (si no lo tienes):
    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```
    *Asegúrate de reiniciar tu shell o hacer `source` de tu archivo de perfil si te lo pide.*

2.  **Instalar `cookiecutter`**:
    ```bash
    uv tool install cookiecutter
    ```

3.  **Verificación**:
    ```bash
    cookiecutter --version
    ```

### 3. Configuración de Node.js con `nvm`

Usaremos `nvm` para instalar la versión LTS de Node.js y las herramientas CLI necesarias (como `npm` y `gemini`).

1.  **Instalar `nvm`** (si no lo tienes):
    ```bash
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    # Cierra y abre la terminal o carga nvm:
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    ```

2.  **Instalar Node.js LTS**:
    ```bash
    nvm install --lts
    nvm use --lts
    ```

3.  **Instalar dependencias globales**:
    Requerimos una versión reciente de npm.
    ```bash
    npm install -g npm@latest
    ```

4.  **Verificación**:
    ```bash
    node --version
    npm --version
    ```

## Ejecución del Proyecto

Una vez configurado el entorno, puedes usar el proyecto tal como se hace en el devcontainer.

1.  **Clonar el repositorio** (si aún no lo has hecho):
    ```bash
    git clone https://github.com/tu-usuario/cookiecutter.git
    cd cookiecutter
    ```

2.  **Generar un proyecto**:
    ```bash
    cookiecutter . --output-dir output
    ```

3.  **Ejecutar pruebas (ejemplo)**:
    Si has generado un proyecto en `output/mi-proyecto`:
    ```bash
    cd output/mi-proyecto
    docker compose up -d
    # O ejecutar los scripts de verificación correspondientes
    ```

## Solución de Problemas Comunes

*   **Permisos de Docker**: Si recibes errores de `permission denied` al conectar con el socket de Docker, revisa que tu usuario esté en el grupo `docker` (Paso 1).
*   **Comandos no encontrados**: Asegúrate de que las rutas de `uv` (`~/.local/bin` o similar) y `nvm` estén en tu `$PATH`.
