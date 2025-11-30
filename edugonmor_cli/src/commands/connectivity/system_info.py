"""
System-info command - Display remote server system information.

Shows installed software versions and user permissions on the connected server.

https://typer.tiangolo.com/tutorial/commands/
"""

from typing import Optional

import typer

from src.services.connectivity.ssh_client import SSHService
from src.services.connectivity.system_check import SystemCheckService
from src.services.session import load_session
from src.ui import (
    console,
    print_error,
    print_info,
    print_success,
    print_warning,
)
from src.ui.panels.status import print_system_info_panel


def system_info(
    sudo_password: Optional[str] = typer.Option(
        None,
        "--sudo-password",
        "-s",
        help="Sudo password to verify sudo access",
        hide_input=True,
    ),
) -> None:
    """
    Muestra información del sistema del servidor remoto.

    Verifica si Python 3, Docker y Docker Compose están instalados,
    y si el usuario tiene permisos sudo.

    Requires:
        An active SSH session (use 'edugonmor connect' first).
    """
    # Load session
    session = load_session()

    if session is None:
        print_error("No hay ninguna sesión SSH configurada.")
        print_info("Usa 'edugonmor connect' para establecer una conexión primero.")
        raise typer.Exit(code=1)

    print_info(f"🔄 Conectando a {session.user}@{session.host}...")

    # Create SSH connection
    ssh = SSHService(
        host=session.host,
        user=session.user,
        port=session.port,
        password=session.password,
    )

    # Test connection first
    if not ssh.test_connection():
        print_error("❌ No se puede conectar al servidor.")
        print_warning(
            "Verifica que el servidor esté disponible y las credenciales sean válidas."
        )
        raise typer.Exit(code=1)

    print_success("✅ Conexión establecida")
    print_info("🔍 Analizando sistema remoto...")
    console.print()

    # Run system check
    checker = SystemCheckService(ssh)
    result = checker.run_full_check(sudo_password=sudo_password)

    # Display results using the panel
    print_system_info_panel(
        host=session.host,
        user=session.user,
        result=result,
    )
