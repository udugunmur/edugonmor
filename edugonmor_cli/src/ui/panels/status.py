"""
Status panels for displaying connection and operation states.

https://rich.readthedocs.io/en/latest/panel.html
"""

from typing import TYPE_CHECKING, Optional

from rich.panel import Panel
from rich.table import Table
from rich.text import Text

from src.ui.console import console

if TYPE_CHECKING:
    from src.services.connectivity.system_check import SystemCheckResult


def print_connection_status(
    host: str,
    user: str,
    port: int,
    connected: bool,
    error: Optional[str] = None,
) -> None:
    """
    Display a panel showing SSH connection status.

    Args:
        host: The remote host address.
        user: The SSH username.
        port: The SSH port.
        connected: Whether the connection is active.
        error: Optional error message if connection failed.
    """
    if connected:
        status_icon = "[bold green]●[/bold green]"
        status_text = "Connected"
        border_style = "green"
    else:
        status_icon = "[bold red]●[/bold red]"
        status_text = "Disconnected"
        border_style = "red"

    content = Text()
    content.append(f"Status: {status_icon} {status_text}\n")
    content.append(f"Host:   {host}\n", style="cyan")
    content.append(f"User:   {user}\n", style="cyan")
    content.append(f"Port:   {port}", style="cyan")

    if error:
        content.append(f"\n\nError: {error}", style="red")

    panel = Panel(
        content,
        title="🔌 SSH Connection",
        border_style=border_style,
    )
    console.print(panel)


def print_operation_status(
    operation: str,
    success: bool,
    details: Optional[str] = None,
) -> None:
    """
    Display a panel showing operation result.

    Args:
        operation: Name of the operation performed.
        success: Whether the operation succeeded.
        details: Optional additional details.
    """
    if success:
        icon = "✅"
        border_style = "green"
        title = f"{icon} {operation} - Success"
    else:
        icon = "❌"
        border_style = "red"
        title = f"{icon} {operation} - Failed"

    content = details if details else "Operation completed."

    panel = Panel(
        content,
        title=title,
        border_style=border_style,
    )
    console.print(panel)


def print_system_info_panel(
    host: str,
    user: str,
    result: "SystemCheckResult",
) -> None:
    """
    Display a panel showing remote system information.

    Args:
        host: The remote host address.
        user: The SSH username.
        result: The system check result containing software info.
    """
    # OS type icons
    os_icons = {
        "macos": "🍎 macOS",
        "linux": "🐧 Linux",
        "windows": "🪟 Windows",
        "unknown": "❓ Unknown",
    }
    os_display = os_icons.get(result.os_type or "unknown", "❓ Unknown")

    # Create software table
    table = Table(show_header=True, header_style="bold cyan", box=None)
    table.add_column("Software", style="white", width=20)
    table.add_column("Status", justify="center", width=12)
    table.add_column("Version", style="dim", width=25)

    # Python 3
    if result.python3.installed:
        py_status = "[bold green]✅ Installed[/bold green]"
        py_version = result.python3.version or "Unknown"
    else:
        py_status = "[bold red]❌ Not Found[/bold red]"
        py_version = result.python3.error or "-"
    table.add_row("🐍 Python 3", py_status, py_version)

    # Docker
    if result.docker.installed:
        docker_status = "[bold green]✅ Installed[/bold green]"
        docker_version = result.docker.version or "Unknown"
    else:
        docker_status = "[bold red]❌ Not Found[/bold red]"
        docker_version = result.docker.error or "-"
    table.add_row("🐳 Docker", docker_status, docker_version)

    # Docker Compose
    if result.docker_compose.installed:
        compose_status = "[bold green]✅ Installed[/bold green]"
        compose_version = result.docker_compose.version or "Unknown"
    else:
        compose_status = "[bold red]❌ Not Found[/bold red]"
        compose_version = result.docker_compose.error or "-"
    table.add_row("📦 Docker Compose", compose_status, compose_version)

    # Sudo access
    if result.has_sudo:
        sudo_status = "[bold green]✅ Yes[/bold green]"
        sudo_info = "User has sudo privileges"
    else:
        sudo_status = "[bold yellow]⚠️ No[/bold yellow]"
        sudo_info = result.sudo_error or "No sudo access"
    table.add_row("🔐 Sudo Access", sudo_status, sudo_info)

    # Header text
    header = Text()
    header.append("Host: ", style="bold")
    header.append(f"{host}\n", style="cyan")
    header.append("User: ", style="bold")
    header.append(f"{user}\n", style="cyan")
    header.append("OS:   ", style="bold")
    header.append(f"{os_display}\n\n", style="magenta")

    # Combine content
    from rich.console import Group

    content = Group(header, table)

    panel = Panel(
        content,
        title="🖥️  Remote System Information",
        border_style="blue",
        padding=(1, 2),
    )
    console.print(panel)
