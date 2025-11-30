"""
Herramientas de Git.
"""

import subprocess
from pathlib import Path


def init_repo(path: Path) -> bool:
    """
    Inicializa un repositorio git en la ruta destino.

    Args:
        path: Ruta donde inicializar el repositorio.

    Returns:
        bool: True si tuvo éxito, False si falló.

    Raises:
        FileNotFoundError: Si la ruta no existe.
    """
    if not path.exists():
        raise FileNotFoundError(f"La ruta {path} no existe")

    try:
        subprocess.run(["git", "init"], cwd=path, check=True, capture_output=True)
        return True
    except subprocess.CalledProcessError:
        return False
