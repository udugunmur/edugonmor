"""
Cliente SSH usando Fabric.
https://docs.fabfile.org/en/stable/
"""

import socket
from dataclasses import dataclass
from typing import Optional

from fabric import Connection
from invoke.exceptions import AuthFailure, UnexpectedExit


@dataclass
class CommandResult:
    """Resultado de la ejecución de un comando remoto."""

    success: bool
    output: str
    error: str = ""


class SSHService:
    """Gestor de conexiones remotas usando Fabric."""

    def __init__(
        self, host: str, user: str, password: Optional[str] = None, port: int = 22
    ):
        self.host = host
        self.user = user
        self.port = port
        self._password = password

        connect_kwargs = {}
        if password:
            connect_kwargs["password"] = password

        self.connection = Connection(
            host=host,
            user=user,
            port=port,
            connect_kwargs=connect_kwargs,
            connect_timeout=5,
        )

    def test_connection(self) -> bool:
        """Verifica si la conexión es posible."""
        result = self.run_safe("exit 0")
        return result.success

    def run_safe(self, command: str) -> CommandResult:
        """
        Ejecuta un comando y captura errores sin romper el programa.

        Args:
            command (str): El comando de bash a ejecutar.

        Returns:
            CommandResult: Objeto con el estado de la ejecución.
        """
        try:
            result = self.connection.run(command, hide=True, warn=True)
            return CommandResult(success=result.ok, output=result.stdout.strip())
        except (AuthFailure, socket.error, socket.timeout) as e:
            return CommandResult(
                success=False, output="", error=f"Error de conexión: {e}"
            )
        except UnexpectedExit as e:
            return CommandResult(success=False, output="", error=str(e))
        except Exception as e:
            return CommandResult(
                success=False, output="", error=f"Error inesperado: {e}"
            )
