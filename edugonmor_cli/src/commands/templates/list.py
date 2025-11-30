"""
List templates command - Show all available project templates.

https://typer.tiangolo.com/tutorial/commands/
"""

from src.ui import print_info, print_warning


def list_templates() -> None:
    """
    Lista todas las plantillas de proyecto disponibles.

    Muestra una tabla con las plantillas registradas, incluyendo
    nombre, descripción y versión.
    """
    # TODO: Implement template discovery
    print_info("Plantillas disponibles:")
    print_warning("⚠️ Comando en desarrollo. Próximamente disponible.")
