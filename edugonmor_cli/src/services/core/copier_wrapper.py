"""
Wrapper para Copier (Lógica central del generador).
https://copier.readthedocs.io/en/stable/api/
"""

from pathlib import Path
from typing import Any, Dict, Optional

import copier

from src.config import settings


def generate_project(
    project_name: str,
    output_dir: Optional[Path] = None,
    template_path: Optional[str] = None,
    data: Optional[Dict[str, Any]] = None,
) -> Path:
    """
    Genera un nuevo proyecto usando Copier.

    Args:
        project_name: Nombre del proyecto a crear.
        output_dir: Directorio donde se creará el proyecto.
        template_path: Ruta a la plantilla (default: built-in template).
        data: Datos adicionales para pasar a la plantilla.

    Returns:
        Path: Ruta al proyecto creado.
    """
    template = template_path or settings.default_template_path
    destination = Path(output_dir or settings.output_dir) / project_name

    # Preparar respuestas
    answers = {"project_name": project_name}
    if data:
        answers.update(data)

    # Ejecutar Copier
    copier.run_copy(
        src_path=template,
        dst_path=destination,
        data=answers,
        unsafe=True,  # Permitir ejecución sin git
    )

    return destination


def update_project(
    project_path: Path,
    skip_answered: bool = True,
) -> None:
    """
    Actualiza un proyecto existente con los últimos cambios de la plantilla.

    Args:
        project_path: Ruta al proyecto a actualizar.
        skip_answered: Saltar preguntas ya respondidas.
    """
    copier.run_update(
        dst_path=project_path,
        skip_answered=skip_answered,
        unsafe=True,
    )
