"""
Config command - Show current CLI configuration.

https://typer.tiangolo.com/tutorial/commands/
https://docs.pydantic.dev/latest/
"""

from src.config import settings
from src.ui import print_dict_table


def show_config() -> None:
    """
    Muestra la configuración actual del CLI.

    Incluye rutas de plantillas, configuración de registro
    y otros valores de entorno.
    """
    config_data = {
        "Template Path": str(settings.default_template_path),
        "Workspace Path": str(settings.workspace_path),
        "Nexus Registry": settings.nexus_registry or "Not configured",
    }

    print_dict_table("CLI Configuration", config_data)
