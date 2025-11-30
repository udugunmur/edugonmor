# 🚀 edugonmor_cli

> **Standardized Project Generator & Remote Deployment Tool**
>
> This tool allows you to generate project structures based on templates, both locally and on remote servers via SSH, using a Docker-first approach.

## 📚 About this Documentation
*   **`README.md` (This file):** Technical manual for **Humans**. Explains usage, architecture, and extensibility.
*   **`agent.md`:** Master Protocol for **AI Agents**. Defines strict coding rules, workflow, and security policies.

---

# 👤 USER GUIDE (Quick Start)

## 🐳 Quick Start

The CLI runs inside Docker. You don't need to install Python locally.

```bash
# 1. Build the image (first time only)
make build

# 2. Create a new project
make create NAME=my-new-project

# 3. List available templates
make run list templates
```

## 🛠️ Common Commands

| Command | Description |
|---------|-------------|
| `make build` | Builds the Docker image. |
| `make run` | **Starts the persistent environment.** Opens a shell that stays alive. |
| `make test` | Run tests inside Docker. |
| `make lint` | Check code quality inside Docker. |
| `make format` | Auto-format code inside Docker. |

## 🔄 Flujo de Uso Progresivo

El CLI organiza los comandos en **3 grupos** según el estado de conexión:

```bash
# Ver todos los comandos disponibles
edugonmor --help
```

### 📡 Conexión SSH (siempre disponibles)
```bash
edugonmor connect --host 192.168.1.214 --user root  # Establecer conexión
edugonmor status                                      # Ver estado actual
edugonmor disconnect                                  # Cerrar sesión
```

### 🔐 Remotos (requieren conexión SSH activa)
```bash
# ⚠️ Estos comandos FALLAN si no hay conexión SSH
edugonmor system-info                    # Info del servidor remoto
edugonmor create my-project              # Crear proyecto en remoto
edugonmor update my-project              # Actualizar proyecto
```

### 📦 Local (no requieren SSH)
```bash
edugonmor templates                      # Listar plantillas locales
edugonmor template-info my-template      # Ver detalles de plantilla
edugonmor version                        # Versión del CLI
edugonmor config                         # Configuración actual
```

## 🖥️ System Info Command

After connecting to a remote server, you can check its configuration:

```bash
# Connect first
edugonmor connect --host 192.168.1.214 --user myuser

# Check system info (Python, Docker, Docker Compose, sudo access)
edugonmor system-info

# With sudo password verification
edugonmor system-info --sudo-password 'mypassword'
```

**Output example:**
```
╭─────────────────── 🖥️  Remote System Information ───────────────────╮
│  Host: 192.168.1.214                                                │
│  User: myuser                                                       │
│  OS:   🍎 macOS                                                     │
│                                                                     │
│   Software              Status       Version                        │
│   🐍 Python 3        ✅ Installed   3.9.6                           │
│   🐳 Docker          ✅ Installed   28.5.2                          │
│   📦 Docker Compose  ✅ Installed   v2.40.3                         │
│   🔐 Sudo Access     ✅ Yes        User has sudo privileges         │
╰─────────────────────────────────────────────────────────────────────╯
```

**Supported platforms:** Linux 🐧, macOS 🍎, Windows (WSL) 🪟

---

# 🏗️ ARCHITECT & MAINTAINER GUIDE

> **Technical Documentation for the Standardized Project Generator**
>
> This section focuses on the internal architecture, modular design, and extensibility of the CLI.

## 📐 Architectural Philosophy

This project follows a **Docker-first** approach combined with a **Domain-Driven Modular Architecture** for its internal services.

### 1. Docker-First Execution Model & Persistence
The CLI is designed to run **exclusively** inside a Docker container.
- **Consistency**: No "works on my machine" issues.
- **Sticky Session**: The container uses a custom `entrypoint.sh` that executes commands and then **drops into an interactive shell** instead of exiting. This allows developers to chain commands without restarting the container.

### 2. Modular Service Architecture
The codebase has been refactored from a monolithic script into a domain-centric service layer.

| Domain | Package | Responsibility | Key Libraries |
|--------|---------|----------------|---------------|
| **Core** | `src.services.core` | Template generation & updates | `copier` |
| **Connectivity** | `src.services.connectivity` | Remote execution & SSH | `fabric`, `paramiko` |
| **Tools** | `src.services.tools` | System utilities (Git, OS) | `subprocess` |
| **Validators** | `src.services.validators` | Input validation logic | `pydantic` |

## 🗺️ Source Code Structure

The `src/` directory is the heart of the application. Here is the strict hierarchy:

```text
src/
├── commands/                 # 🎮 CLI Interface (Typer)
│   ├── __init__.py           # Facade (Exposes all commands)
│   ├── connectivity/         # Domain: Connection management
│   │   ├── __init__.py
│   │   ├── connect.py        # edugonmor connect
│   │   ├── disconnect.py     # edugonmor disconnect
│   │   ├── status.py         # edugonmor status
│   │   └── system_info.py    # edugonmor system-info
│   ├── project/              # Domain: Project management
│   │   ├── __init__.py
│   │   ├── create.py         # edugonmor create
│   │   └── update.py         # edugonmor update
│   ├── templates/            # Domain: Template management
│   │   ├── __init__.py
│   │   ├── list.py           # edugonmor templates
│   │   └── info.py           # edugonmor template-info
│   └── system/               # Domain: System utilities
│       ├── __init__.py
│       ├── version.py        # edugonmor version
│       └── config.py         # edugonmor config
│
├── services/                 # 🧠 Business Logic Layer
│   ├── __init__.py           # Facade (Exposes key services)
│   ├── session.py            # Persistent session management
│   ├── core/                 # Core Generation Logic
│   │   └── copier_wrapper.py # Wraps Copier API
│   ├── connectivity/         # Remote Access
│   │   ├── ssh_client.py     # Fabric-based SSH client
│   │   ├── wizard.py         # 🧙 Interactive SSH Connection Wizard
│   │   └── system_check.py   # 🖥️ Remote system diagnostics
│   ├── tools/                # Utilities
│   │   └── git.py            # Git operations
│   └── validators/           # Data Validation
│
├── ui/                       # 🎨 Presentation Layer (Rich)
│   ├── __init__.py           # Facade (Exposes key UI functions)
│   ├── console.py            # Console singleton
│   ├── components/           # Atomic UI elements
│   │   ├── messages.py       # print_success, print_error, etc.
│   │   ├── progress.py       # Spinners and progress bars
│   │   └── tables.py         # Formatted tables
│   ├── panels/               # Composite UI elements
│   │   ├── status.py         # Connection status panels
│   │   └── results.py        # Operation result panels
│   ├── prompts/              # Interactive inputs
│   │   ├── inputs.py         # ask, confirm, choose
│   │   └── wizards.py        # Multi-step wizards
│   └── themes/               # Styling and colors
│       └── colors.py         # Color palette and icons
│
├── config.py                 # ⚙️ Configuration (Pydantic Settings)
└── main.py                   # 🚀 Entry Point
```

## 🧩 Key Components Detail

### 1. Connectivity Service (`src.services.connectivity`)
Handles all remote interactions via SSH.
- **Class**: `SSHService`
- **Wizard**: `wizard.py` provides an interactive loop (`get_ssh_connection`) that prompts the user for credentials (Host, User, Password) if they are missing or if authentication fails, ensuring a smooth UX.
- **System Check**: `system_check.py` provides `SystemCheckService` to verify remote system configuration (Python, Docker, sudo access).
- **Features**:
    - Automatic connection testing (`test_connection`).
    - Safe command execution with error capturing (`run_safe`).
    - Returns structured `CommandResult` objects (success, output, error).
    - **Cross-platform support**: Works on Linux, macOS, and Windows (WSL).
- **Usage**:
    ```python
    from src.services import SSHService, SystemCheckService
    
    ssh = SSHService(host="192.168.1.10", user="root")
    result = ssh.run_safe("ls -la")
    
    # System diagnostics
    checker = SystemCheckService(ssh)
    info = checker.run_full_check(sudo_password="secret")
    print(f"Python: {info.python3.version}")
    print(f"Docker: {info.docker.version}")
    ```

### 2. Core Service (`src.services.core`)
Wraps the `copier` library to provide a simplified API for the CLI commands.
- **Functions**: `generate_project`, `update_project`.
- **Logic**: Handles path resolution between the Docker container (`/app/template`) and the mounted workspace (`/workspace`).

### 3. UI Layer (`src.ui`)
Modular presentation layer built on Rich library.

| Domain | Package | Responsibility | Key Functions |
|--------|---------|----------------|---------------|
| **Components** | `src.ui.components` | Atomic UI elements | `print_success`, `spinner` |
| **Panels** | `src.ui.panels` | Composite displays | `print_connection_status` |
| **Prompts** | `src.ui.prompts` | User input | `ask`, `confirm`, `choose` |
| **Themes** | `src.ui.themes` | Styling | `COLORS`, `ICONS` |

- **Usage**:
    ```python
    from src.ui import print_success, ask, spinner
    
    name = ask("Project name")
    with spinner("Creating project..."):
        create_project(name)
    print_success(f"Project {name} created!")
    ```

### 4. Commands Layer (`src.commands`)
Modular CLI command layer built on Typer, organized by business domain.

| Domain | Package | Commands | Description |
|--------|---------|----------|-------------|
| **Connectivity** | `src.commands.connectivity` | `connect`, `disconnect`, `status`, `system-info` | SSH session management |
| **Project** | `src.commands.project` | `create`, `update` | Project operations |
| **Templates** | `src.commands.templates` | `list`, `info` | Template discovery |
| **System** | `src.commands.system` | `version`, `config` | CLI utilities |

- **Usage**:
    ```python
    from src.commands import connect, create, version
    
    # Commands are registered in main.py
    app.command(name="connect")(connect)
    ```

### 5. Configuration (`src.config`)
Uses **Pydantic Settings** to manage environment variables and defaults.
- **File**: `src/config.py`
- **Key Settings**:
    - `default_template_path`: Internal path to the template.
    - `nexus_registry`: Configuration for image pushing.

## 🛠️ Development Workflow

### Prerequisites
- Docker & Docker Compose
- Make

> ⚠️ **IMPORTANT: Docker-First Policy**
> 
> ALL commands (including tests and linting) MUST run inside Docker.
> Do NOT use `pip install`, `pytest`, or `ruff` directly on your host machine.
> See `agent.md` section 4.4 for the complete policy.

### Common Tasks

**1. Build the Development Image**
```bash
make build
```

**2. Run Tests (Pytest inside Docker)**
Tests are located in `tests/` and cover both unit logic and integration scenarios.
```bash
make test
```

**3. Code Quality (Linting & Formatting inside Docker)**
We use `ruff` for both linting and formatting, executed inside Docker.
```bash
make lint    # Check for errors
make format  # Auto-fix formatting
```

**4. Clean Build Artifacts**
```bash
make clean
```

## 🧩 Extending the CLI

### Adding a New Command
1. Identify the domain for your command:
   - **Connectivity**: SSH/connection related → `src/commands/connectivity/`
   - **Project**: Project operations → `src/commands/project/`
   - **Templates**: Template management → `src/commands/templates/`
   - **System**: Utilities/info → `src/commands/system/`
2. Create a new file in the appropriate domain folder (e.g., `src/commands/project/deploy.py`).
3. Define your command function with proper docstrings:
   ```python
   import typer
   from src.ui import print_success
   
   def deploy(name: str = typer.Argument(...)) -> None:
       """Deploy a project to remote server."""
       print_success(f"Deploying {name}...")
   ```
4. Export via the domain's `__init__.py`:
   ```python
   from .deploy import deploy
   __all__ = [..., "deploy"]
   ```
5. Export via the main facade `src/commands/__init__.py`:
   ```python
   from .project import deploy
   __all__ = [..., "deploy"]
   ```
6. Register the command in `src/main.py`:
   ```python
   from src.commands import deploy
   app.command(name="deploy", help="Deploy project")(deploy)
   ```

### Adding a New Service
1. Identify the domain (e.g., `database`).
2. Create a new folder: `src/services/database/`.
3. Implement the logic and expose it via `src/services/__init__.py` if it's a public API.

### Adding a New UI Component
1. Identify the type of component:
   - **Atomic** (simple, reusable): Add to `src/ui/components/`
   - **Composite** (complex panels): Add to `src/ui/panels/`
   - **Interactive** (user input): Add to `src/ui/prompts/`
2. Implement the component with proper docstrings.
3. Export via the facade in `src/ui/__init__.py`:
   ```python
   from .components.my_component import my_function
   
   __all__ = [..., "my_function"]
   ```
4. **Usage pattern** (always use the facade):
   ```python
   # ✅ Correct
   from src.ui import print_success, spinner, ask
   
   # ❌ Avoid (breaks encapsulation)
   from src.ui.components.messages import print_success
   ```

## 📚 Reference Documentation

- **Typer (CLI)**: [https://typer.tiangolo.com/](https://typer.tiangolo.com/)
- **Rich (UI)**: [https://rich.readthedocs.io/](https://rich.readthedocs.io/)
- **Copier (Templates)**: [https://copier.readthedocs.io/](https://copier.readthedocs.io/)
- **Fabric (SSH)**: [https://docs.fabfile.org/](https://docs.fabfile.org/)
- **Pydantic (Config)**: [https://docs.pydantic.dev/](https://docs.pydantic.dev/)

## Estándar de Infraestructura

Este proyecto sigue estrictamente el patrón de infraestructura "Edugonmor Pattern". Cualquier modificación en `docker-compose.yml` debe respetar las siguientes reglas:

1.  **Nomenclatura de Servicios:**
    *   Servicio Principal: `edugonmor_<proyecto>_services`
    *   Servicio de Backup: `edugonmor_<proyecto>_backup`
    *   Contenedores: `container_name: edugonmor_<proyecto>_<rol>`
2.  **Nomenclatura de Volúmenes:**
    *   Datos: `edugonmor_<proyecto>_volumen`
    *   Backups: `edugonmor_<proyecto>_backups`
3.  **Configuración:**
    *   Uso obligatorio de archivo `.env`.
    *   Prohibido el uso de Docker Secrets (`secrets:`).
    *   Credenciales inyectadas vía variables de entorno.
4.  **Redes:**
    *   Red dedicada: `edugonmor_<proyecto>_network`
