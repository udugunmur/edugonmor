"""
Main entry point for the CLI application.
https://typer.tiangolo.com/
"""

import typer

from src.commands import (
    connect,
    create,
    disconnect,
    list_templates,
    show_config,
    status,
    system_info,
    template_info,
    update,
    version,
)
from src.services.connectivity.ssh_client import SSHService
from src.services.session import load_session
from src.ui import print_error, print_info

# =============================================================================
# PANEL NAMES (Rich Help Panels)
# =============================================================================
PANEL_CONNECTION = "📡 Conexión SSH"
PANEL_REMOTE = "🔐 Remotos"
PANEL_LOCAL = "📦 Local"

app = typer.Typer(
    name="edugonmor",
    help="🚀 CLI para generar estructuras de proyecto estandarizadas.",
    add_completion=False,
    no_args_is_help=False,  # Changed: allow no args for shell mode
    rich_markup_mode="rich",
)

# =============================================================================
# 📡 CONEXIÓN SSH (siempre disponibles)
# =============================================================================
app.command(
    name="connect",
    help="Establecer conexión SSH persistente",
    rich_help_panel=PANEL_CONNECTION,
)(connect)
app.command(
    name="disconnect",
    help="Cerrar sesión SSH actual",
    rich_help_panel=PANEL_CONNECTION,
)(disconnect)
app.command(
    name="status",
    help="Ver estado de conexión actual",
    rich_help_panel=PANEL_CONNECTION,
)(status)

# =============================================================================
# 🔐 REMOTOS (siempre registrados, validación en runtime)
# =============================================================================
app.command(
    name="system-info",
    help="Información del sistema remoto",
    rich_help_panel=PANEL_REMOTE,
)(system_info)
app.command(
    name="create",
    help="Crear nuevo proyecto desde plantilla",
    rich_help_panel=PANEL_REMOTE,
)(create)
app.command(
    name="update",
    help="Actualizar proyecto existente",
    rich_help_panel=PANEL_REMOTE,
)(update)

# =============================================================================
# 📦 LOCAL (no requieren SSH)
# =============================================================================
app.command(
    name="templates",
    help="Listar plantillas disponibles",
    rich_help_panel=PANEL_LOCAL,
)(list_templates)
app.command(
    name="template-info",
    help="Ver detalles de una plantilla",
    rich_help_panel=PANEL_LOCAL,
)(template_info)
app.command(
    name="version",
    help="Mostrar versión del CLI",
    rich_help_panel=PANEL_LOCAL,
)(version)
app.command(
    name="config",
    help="Mostrar configuración actual",
    rich_help_panel=PANEL_LOCAL,
)(show_config)


# =============================================================================
# COMMAND CLASSIFICATION
# =============================================================================
# Commands that NEVER require SSH session
NO_SSH_COMMANDS = [
    "connect",
    "disconnect",
    "status",
    "version",
    "config",
    "templates",
    "template-info",
]

# Commands that ALWAYS require SSH session
SSH_REQUIRED_COMMANDS = [
    "system-info",
    "create",
    "update",
]


@app.callback()
def main(
    ctx: typer.Context,
) -> None:
    """
    edugonmor CLI - Genera estructuras de proyecto estandarizadas.

    Punto de entrada principal del CLI. Gestiona la validación de sesión SSH
    y proporciona el contexto necesario a los subcomandos.

    Esta herramienta está diseñada para trabajar remotamente vía SSH.
    Usa 'connect' primero para establecer conexión.

    Args:
        ctx (typer.Context): Contexto de Typer con información del comando.

    Returns:
        None

    Raises:
        typer.Exit: Si un comando requiere SSH y no hay sesión activa.
    """
    # Allow --help to work for any command without SSH validation
    if ctx.resilient_parsing:
        return

    # Commands that don't need any session handling
    if ctx.invoked_subcommand in NO_SSH_COMMANDS:
        return

    # Commands that REQUIRE SSH - load session and create SSH service
    if ctx.invoked_subcommand in SSH_REQUIRED_COMMANDS:
        session = load_session()

        if not session:
            print_error("❌ Este comando requiere conexión SSH activa")
            print_info("💡 Usa 'connect --host <IP> --user <USER>' primero")
            raise typer.Exit(code=1)

        # Create SSH service from saved session
        print_info(f"🔄 Usando sesión: {session.user}@{session.host}")
        ssh = SSHService(
            host=session.host,
            user=session.user,
            port=session.port,
            password=session.password,
        )

        # Store in context for subcommands
        ctx.obj = {"ssh": ssh}
        return

    # Default: pass empty context
    ctx.obj = {"ssh": None}


if __name__ == "__main__":
    app()
