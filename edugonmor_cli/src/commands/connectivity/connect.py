"""
Connect command - Establish and persist a connection session.

https://typer.tiangolo.com/tutorial/options/
https://typer.tiangolo.com/tutorial/options/password/
https://docs.fabfile.org/en/stable/
"""

from typing import Optional

import typer

from src.services.connectivity.wizard import get_ssh_connection
from src.services.session import save_session
from src.ui import print_info, print_success, print_warning


def connect(
    host: str = typer.Option(..., help="Remote SSH host"),
    user: str = typer.Option(..., help="Remote SSH user"),
    port: int = typer.Option(22, help="Remote SSH port"),
    password: Optional[str] = typer.Option(
        None,
        "--password",
        "-p",
        help="SSH password (will prompt if not provided)",
    ),
) -> None:
    """
    Establece una sesión persistente con el servidor remoto.

    Utiliza el wizard interactivo para validar las credenciales SSH
    y guarda la sesión en RAM disk para comandos posteriores.

    Args:
        host (str): Dirección IP o hostname del servidor remoto.
        user (str): Nombre de usuario SSH para la conexión.
        port (int): Puerto SSH (default: 22).
        password (Optional[str]): Contraseña SSH. Si no se proporciona,
            el wizard la solicitará interactivamente.

    Returns:
        None

    Raises:
        typer.Exit: Si la conexión falla o el usuario cancela.

    Example:
        $ edugonmor connect --host 192.168.1.214 --user root --password secret
        $ edugonmor connect --host 192.168.1.214 --user root  # prompts password
    """
    print_info("Iniciando configuración de sesión persistente...")

    # Usamos el wizard existente para obtener una conexión válida
    ssh = get_ssh_connection(host=host, user=user, port=port, password=password)

    # Si llegamos aquí, la conexión fue exitosa. Guardamos la sesión.
    save_session(host=ssh.host, user=ssh.user, port=ssh.port, password=ssh._password)

    print_success(f"✅ Sesión guardada para {ssh.user}@{ssh.host}")
    print_warning("⚠️  Las credenciales se guardan temporalmente en este contenedor.")
    print_warning("   Se perderán al salir del contenedor (exit).")
