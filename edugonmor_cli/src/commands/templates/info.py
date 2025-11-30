"""
Template info command - Show detailed information about a template.

https://typer.tiangolo.com/tutorial/commands/
"""

import typer

from src.ui import print_info, print_warning


def info(
    template_name: str = typer.Argument(..., help="Name of the template to inspect"),
) -> None:
    """
    Muestra información detallada de una plantilla específica.

    Incluye descripción, variables requeridas, valores por defecto
    y estructura de archivos generados.

    Args:
        template_name: Nombre de la plantilla a inspeccionar.
    """
    # TODO: Implement template inspection
    print_info(f"Información de la plantilla '{template_name}':")
    print_warning("⚠️ Comando en desarrollo. Próximamente disponible.")
