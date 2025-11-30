"""
Multi-step wizard interfaces for complex user flows.

https://rich.readthedocs.io/en/latest/prompt.html
https://rich.readthedocs.io/en/latest/panel.html
"""

from dataclasses import dataclass
from typing import Optional

from rich.panel import Panel

from src.ui.console import console
from src.ui.prompts.inputs import ask, ask_int, confirm


@dataclass
class SSHCredentials:
    """Data class for SSH connection credentials."""

    host: str
    user: str
    port: int
    password: Optional[str] = None


def ssh_connection_wizard(
    default_host: Optional[str] = None,
    default_user: Optional[str] = None,
    default_port: int = 22,
) -> SSHCredentials:
    """
    Interactive wizard for collecting SSH connection details.

    Args:
        default_host: Pre-filled host value.
        default_user: Pre-filled username.
        default_port: Default SSH port.

    Returns:
        SSHCredentials: The collected credentials.
    """
    console.print(
        Panel(
            "[bold]SSH Connection Setup[/bold]\n\n"
            "Please provide the connection details for the remote server.",
            title="🔐 Connection Wizard",
            border_style="blue",
        )
    )

    host = ask("Host (IP or hostname)", default=default_host)
    user = ask("Username", default=default_user)
    port = ask_int("Port", default=default_port, min_value=1, max_value=65535)
    password = ask("Password", password=True)

    return SSHCredentials(
        host=host,
        user=user,
        port=port,
        password=password if password else None,
    )


@dataclass
class ProjectConfig:
    """Data class for project generation configuration."""

    name: str
    description: str
    author: str
    with_docker: bool
    with_tests: bool


def project_creation_wizard(
    default_author: Optional[str] = None,
) -> ProjectConfig:
    """
    Interactive wizard for collecting project configuration.

    Args:
        default_author: Pre-filled author name.

    Returns:
        ProjectConfig: The collected project configuration.
    """
    console.print(
        Panel(
            "[bold]New Project Setup[/bold]\n\nLet's configure your new project.",
            title="📦 Project Wizard",
            border_style="green",
        )
    )

    name = ask("Project name")
    description = ask("Project description", default="A new project")
    author = ask("Author", default=default_author)
    with_docker = confirm("Include Docker configuration?", default=True)
    with_tests = confirm("Include test structure?", default=True)

    return ProjectConfig(
        name=name,
        description=description,
        author=author,
        with_docker=with_docker,
        with_tests=with_tests,
    )
