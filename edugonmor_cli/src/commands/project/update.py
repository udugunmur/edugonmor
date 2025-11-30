"""
Update command - Update an existing project with template changes.

https://typer.tiangolo.com/tutorial/commands/
https://copier.readthedocs.io/en/stable/api/
"""

from pathlib import Path
from typing import Optional

import typer

from src.ui import print_info, print_warning


def update(
    project_path: Optional[str] = typer.Argument(
        None, help="Path to the project to update (default: current directory)"
    ),
    skip_answered: bool = typer.Option(
        True,
        "--skip-answered/--no-skip-answered",
        help="Skip questions that were already answered",
    ),
) -> None:
    """
    Actualiza un proyecto existente con los últimos cambios de la plantilla.

    Sincroniza el proyecto con la versión más reciente de la plantilla
    manteniendo las respuestas anteriores.

    Args:
        project_path: Ruta al proyecto a actualizar.
        skip_answered: Si debe omitir preguntas ya respondidas.
    """
    # TODO: Implement with copier_wrapper when ready
    path = Path(project_path) if project_path else Path.cwd()
    print_info(f"Actualizando proyecto en '{path}'...")
    print_warning("⚠️ Comando en desarrollo. Próximamente disponible.")
