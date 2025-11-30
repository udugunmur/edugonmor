"""
Version command - Show CLI version information.

https://typer.tiangolo.com/tutorial/commands/
"""

from importlib.metadata import PackageNotFoundError
from importlib.metadata import version as get_version

from src.ui import console


def version() -> None:
    """
    Muestra la versión actual del CLI y sus dependencias principales.

    Útil para debugging y reporte de issues.
    """
    try:
        cli_version = get_version("edugonmor-cli")
    except PackageNotFoundError:
        cli_version = "dev"

    console.print(
        f"[bold cyan]edugonmor-cli[/bold cyan] version "
        f"[bold green]{cli_version}[/bold green]"
    )
    console.print("")

    # Show key dependencies
    deps = ["typer", "rich", "copier", "fabric", "pydantic"]
    console.print("[dim]Dependencies:[/dim]")

    for dep in deps:
        try:
            dep_version = get_version(dep)
            console.print(f"  [cyan]{dep}[/cyan]: {dep_version}")
        except PackageNotFoundError:
            console.print(f"  [cyan]{dep}[/cyan]: [dim]not installed[/dim]")
