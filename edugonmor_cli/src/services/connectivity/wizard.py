"""
Wizard interactivo para establecer conexiones SSH.
"""

from typing import Optional

import typer
from rich.prompt import Confirm, Prompt

from src.services.connectivity.ssh_client import SSHService
from src.ui import print_error, print_info, print_success


def get_ssh_connection(
    host: Optional[str] = None,
    user: Optional[str] = None,
    port: int = 22,
    password: Optional[str] = None,
) -> SSHService:
    """
    Obtiene una conexión SSH válida, solicitando credenciales si es necesario.

    Si los parámetros no se proporcionan, inicia un modo interactivo para
    solicitarlos al usuario. Realiza pruebas de conexión y permite reintentar
    en caso de fallo.

    Args:
        host (Optional[str]): Hostname o IP del servidor.
        user (Optional[str]): Usuario SSH.
        port (int): Puerto SSH (default: 22).
        password (Optional[str]): Contraseña SSH.

    Returns:
        SSHService: Una instancia conectada y verificada del servicio SSH.

    Raises:
        typer.Exit: Si el usuario cancela o no logra conectar tras varios intentos.
    """
    while True:
        # 1. Solicitar datos faltantes
        if not host:
            print_info("🔌 Se requiere conexión remota")
            host = Prompt.ask("SSH Host")

        if not user:
            user = Prompt.ask("SSH User", default="root")

        # La contraseña siempre se pide si no viene por argumento (seguridad)
        # O si falló el intento anterior y estamos reintentando
        if not password:
            password = Prompt.ask("SSH Password", password=False)

        # 2. Intentar conectar
        print_info(f"Conectando a {user}@{host}:{port}...")
        ssh = SSHService(host=host, user=user, password=password, port=port)

        if ssh.test_connection():
            print_success(f"Conexión exitosa a {host}")
            return ssh

        # 3. Manejo de errores
        print_error(f"No se pudo conectar a {host}. Verifique sus credenciales.")

        if not Confirm.ask("¿Desea intentar de nuevo?"):
            print_error("Operación cancelada por el usuario.")
            raise typer.Exit(code=1)

        # Reiniciar variables para forzar nueva solicitud.
        # Si falla, asumimos que quiere corregir algo.
        # Reseteamos password para pedirla de nuevo.
        # KISS: Si reintenta, asume que la password estaba mal.
        # Si quiere cambiar host, que cancele y corra de nuevo.
        password = None
