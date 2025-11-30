"""
Servicio de gestión de sesión persistente.
Permite guardar y cargar credenciales de conexión SSH en un archivo local.
"""

import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

# RAM Disk: credenciales volátiles, nunca tocan disco.
# Solo viven mientras dure la instancia del contenedor.
SESSION_FILE = Path("/dev/shm") / ".edugonmor_session"


@dataclass
class SessionData:
    host: str
    user: str
    port: int
    password: Optional[str] = None


def save_session(
    host: str, user: str, port: int, password: Optional[str] = None
) -> None:
    """
    Guarda las credenciales de sesión en un archivo seguro.

    Almacena los datos de conexión SSH en un archivo en RAM disk (/dev/shm)
    con permisos restrictivos (600) para proteger las credenciales.

    Args:
        host (str): Dirección IP o hostname del servidor remoto.
        user (str): Nombre de usuario SSH.
        port (int): Puerto SSH (normalmente 22).
        password (Optional[str]): Contraseña SSH. None si usa key-based auth.

    Returns:
        None

    Raises:
        PermissionError: Si no se puede escribir en /dev/shm.
        OSError: Si falla la operación de escritura.
    """
    data = {"host": host, "user": user, "port": port, "password": password}

    # Guardar con permisos restrictivos (600)
    with open(SESSION_FILE, "w") as f:
        json.dump(data, f)

    os.chmod(SESSION_FILE, 0o600)


def load_session() -> Optional[SessionData]:
    """
    Carga la sesión guardada si existe.

    Lee el archivo de sesión desde RAM disk y deserializa los datos
    de conexión SSH. Maneja errores silenciosamente devolviendo None.

    Args:
        None

    Returns:
        Optional[SessionData]: Datos de sesión si existe y es válido,
            None si no existe archivo o hay error de parsing.

    Raises:
        None: Todos los errores son capturados internamente.
    """
    if not SESSION_FILE.exists():
        return None

    try:
        with open(SESSION_FILE, "r") as f:
            data = json.load(f)
            return SessionData(
                host=data["host"],
                user=data["user"],
                port=data.get("port", 22),
                password=data.get("password"),
            )
    except Exception:
        return None


def clear_session() -> None:
    """
    Elimina el archivo de sesión.

    Borra el archivo de credenciales de RAM disk si existe.
    Operación segura: no lanza excepción si el archivo no existe.

    Args:
        None

    Returns:
        None

    Raises:
        PermissionError: Si no se puede eliminar el archivo.
    """
    if SESSION_FILE.exists():
        SESSION_FILE.unlink()
