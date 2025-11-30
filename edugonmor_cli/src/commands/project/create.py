"""
Create command - Generate a new project from template.

https://typer.tiangolo.com/tutorial/commands/
https://copier.readthedocs.io/en/stable/api/
"""

from typing import Optional

import typer

from src.ui import print_info, print_warning


def create(
    name: str = typer.Argument(..., help="Name of the project to create"),
    template: Optional[str] = typer.Option(
        None, "--template", "-t", help="Template to use (default: standard)"
    ),
    output_dir: Optional[str] = typer.Option(
        None, "--output", "-o", help="Output directory (default: current directory)"
    ),
) -> None:
    """
    Crea un nuevo proyecto a partir de una plantilla.

    Genera la estructura del proyecto usando Copier y la plantilla
    especificada. Requiere una conexión SSH activa.

    Args:
        name: Nombre del proyecto a crear.
        template: Plantilla a usar (opcional).
        output_dir: Directorio de salida (opcional).
    """
    # TODO: Implement with copier_wrapper when ready
    print_info(f"Creando proyecto '{name}'...")
    print_warning("⚠️ Comando en desarrollo. Próximamente disponible.")
