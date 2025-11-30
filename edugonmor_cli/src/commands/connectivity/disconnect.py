"""
Disconnect command - Clear the current SSH session.

https://typer.tiangolo.com/tutorial/commands/
"""

import typer

from src.services.session import clear_session, load_session
from src.ui import print_info, print_success, print_warning


def disconnect() -> None:
    """
    Cierra la sesión SSH activa y elimina las credenciales guardadas.

    Este comando elimina las credenciales almacenadas temporalmente
    en el contenedor, forzando al usuario a reconectarse.
    """
    session = load_session()

    if session is None:
        print_warning("No hay ninguna sesión activa.")
        raise typer.Exit(code=0)

    print_info(f"Cerrando sesión de {session.user}@{session.host}...")
    clear_session()
    print_success("Sesión cerrada correctamente.")
