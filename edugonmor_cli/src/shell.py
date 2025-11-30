"""
Interactive shell for edugonmor CLI.

Provides a REPL-style interface with command history, autocompletion,
and persistent session within the shell.

https://python-prompt-toolkit.readthedocs.io/en/master/
"""

import shlex
import sys

from prompt_toolkit import PromptSession
from prompt_toolkit.auto_suggest import AutoSuggestFromHistory
from prompt_toolkit.completion import WordCompleter
from prompt_toolkit.history import InMemoryHistory
from prompt_toolkit.styles import Style
from rich.console import Console
from rich.panel import Panel

from src.services.session import load_session

# Console for Rich output
console = Console()

# Version
VERSION = "0.1.0"

# Available commands (will be updated dynamically based on session)
BASE_COMMANDS = [
    "connect",
    "disconnect",
    "status",
    "templates",
    "template-info",
    "version",
    "config",
    "help",
    "exit",
    "quit",
    "clear",
]

REMOTE_COMMANDS = [
    "system-info",
    "create",
    "update",
]

# Prompt style
PROMPT_STYLE = Style.from_dict(
    {
        "prompt": "#00aa00 bold",
        "host": "#ffaa00",
    }
)


def get_prompt_text() -> str:
    """
    Generate the prompt text based on current session state.

    Returns:
        str: Formatted prompt string showing connection status.
    """
    session = load_session()
    if session:
        return f"edugonmor [{session.user}@{session.host}]> "
    return "edugonmor> "


def get_completer() -> WordCompleter:
    """
    Create a completer with available commands.

    Commands are dynamically adjusted based on whether SSH session exists.

    Returns:
        WordCompleter: Completer instance with available commands.
    """
    session = load_session()
    commands = BASE_COMMANDS.copy()
    if session:
        commands.extend(REMOTE_COMMANDS)
    return WordCompleter(commands, ignore_case=True)


def show_welcome() -> None:
    """Display welcome banner when shell starts."""
    welcome_text = f"""[bold green]🚀 edugonmor CLI v{VERSION}[/bold green]

[dim]Escribe [bold]help[/bold] para ver comandos disponibles.
Escribe [bold]exit[/bold] o presiona [bold]Ctrl+D[/bold] para salir.[/dim]"""

    console.print(
        Panel(
            welcome_text,
            title="[bold blue]Bienvenido[/bold blue]",
            border_style="blue",
        )
    )
    console.print()


def show_help() -> None:
    """Display help with available commands."""
    session = load_session()

    help_text = """[bold cyan]📡 Conexión SSH[/bold cyan]
  [green]connect[/green]      Establecer conexión SSH
  [green]disconnect[/green]   Cerrar sesión SSH actual
  [green]status[/green]       Ver estado de conexión"""

    if session:
        help_text += """

[bold cyan]🔐 Remotos[/bold cyan] [dim](requieren conexión)[/dim]
  [green]system-info[/green]  Información del sistema remoto
  [green]create[/green]       Crear nuevo proyecto
  [green]update[/green]       Actualizar proyecto existente"""

    help_text += """

[bold cyan]📦 Local[/bold cyan]
  [green]templates[/green]    Listar plantillas disponibles
  [green]template-info[/green] Ver detalles de una plantilla
  [green]version[/green]      Mostrar versión del CLI
  [green]config[/green]       Mostrar configuración actual

[bold cyan]🛠️ Shell[/bold cyan]
  [green]help[/green]         Mostrar esta ayuda
  [green]clear[/green]        Limpiar pantalla
  [green]exit[/green]         Salir del CLI"""

    console.print(
        Panel(
            help_text,
            title="[bold]Comandos Disponibles[/bold]",
            border_style="cyan",
        )
    )


def execute_command(command_line: str) -> bool:
    """
    Execute a command entered in the shell.

    Args:
        command_line (str): The full command line entered by user.

    Returns:
        bool: False if shell should exit, True otherwise.
    """
    # Parse command line
    try:
        parts = shlex.split(command_line)
    except ValueError as e:
        console.print(f"[red]❌ Error de sintaxis: {e}[/red]")
        return True

    if not parts:
        return True

    cmd = parts[0].lower()
    args = parts[1:]

    # Built-in shell commands
    if cmd in ("exit", "quit"):
        console.print("[dim]👋 ¡Hasta luego![/dim]")
        return False

    if cmd == "help":
        show_help()
        return True

    if cmd == "clear":
        console.clear()
        return True

    # Delegate to Typer app
    # We need to import here to avoid circular imports
    from typer.testing import CliRunner

    from src.main import app

    runner = CliRunner()

    # Build command for Typer
    typer_args = [cmd] + args

    try:
        result = runner.invoke(app, typer_args, catch_exceptions=False)
        if result.stdout:
            # Print without extra newline since Rich already handles it
            sys.stdout.write(result.stdout)
        if result.stderr:
            sys.stderr.write(result.stderr)
    except SystemExit:
        # Typer raises SystemExit on errors, we catch and continue
        pass
    except Exception as e:
        console.print(f"[red]❌ Error: {e}[/red]")

    return True


def run_shell() -> None:
    """
    Run the interactive shell.

    Creates a prompt session with history and autocompletion,
    then enters a REPL loop until user exits.
    """
    # Show welcome message
    show_welcome()

    # Create prompt session with history
    history = InMemoryHistory()
    session: PromptSession[str] = PromptSession(
        history=history,
        auto_suggest=AutoSuggestFromHistory(),
        style=PROMPT_STYLE,
    )

    # Main REPL loop
    while True:
        try:
            # Update completer each iteration (commands may change after connect)
            completer = get_completer()

            # Get user input
            user_input = session.prompt(
                get_prompt_text(),
                completer=completer,
            )

            # Skip empty input
            if not user_input.strip():
                continue

            # Execute command
            if not execute_command(user_input.strip()):
                break

        except KeyboardInterrupt:
            # Ctrl+C - show message and continue
            console.print("\n[dim]Usa 'exit' para salir[/dim]")
            continue

        except EOFError:
            # Ctrl+D - exit gracefully
            console.print("\n[dim]👋 ¡Hasta luego![/dim]")
            break


def main() -> None:
    """Entry point for the interactive shell."""
    run_shell()


if __name__ == "__main__":
    main()
