"""
Status command - Show current SSH connection status.

https://typer.tiangolo.com/tutorial/commands/
"""

import typer

from src.services.connectivity.ssh_client import SSHService
from src.services.session import load_session
from src.ui import print_error, print_info, print_success, print_warning


def status() -> None:
    """
    Muestra el estado actual de la conexión SSH.

    Verifica si hay una sesión guardada y si la conexión
    sigue siendo válida.
    """
    session = load_session()

    if session is None:
        print_warning("No hay ninguna sesión configurada.")
        print_info("Usa 'edugonmor connect' para establecer una conexión.")
        raise typer.Exit(code=0)

    print_info(f"Sesión encontrada: {session.user}@{session.host}:{session.port}")
    print_info("Verificando conectividad...")

    # Test actual connection
    ssh = SSHService(
        host=session.host,
        user=session.user,
        port=session.port,
        password=session.password,
    )

    if ssh.test_connection():
        print_success("✅ Conexión activa y funcionando.")
    else:
        print_error("❌ La sesión existe pero no se puede conectar.")
        print_warning(
            "Las credenciales pueden haber expirado o el servidor no está disponible."
        )
