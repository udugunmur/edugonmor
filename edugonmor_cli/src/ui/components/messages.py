"""
Message printing utilities for terminal output.
Provides standardized, colored messages for different feedback types.

https://rich.readthedocs.io/en/latest/markup.html
"""

from src.ui.console import console


def print_success(message: str) -> None:
    """
    Print a success message with green checkmark.

    Args:
        message: The message to display.
    """
    console.print(f"[bold green]✓[/bold green] {message}")


def print_error(message: str) -> None:
    """
    Print an error message with red X mark.

    Args:
        message: The error message to display.
    """
    console.print(f"[bold red]✗[/bold red] {message}")


def print_warning(message: str) -> None:
    """
    Print a warning message with yellow warning sign.

    Args:
        message: The warning message to display.
    """
    console.print(f"[bold yellow]⚠[/bold yellow] {message}")


def print_info(message: str) -> None:
    """
    Print an info message with blue info icon.

    Args:
        message: The informational message to display.
    """
    console.print(f"[bold blue]ℹ[/bold blue] {message}")


def print_debug(message: str) -> None:
    """
    Print a debug message with dim styling.

    Args:
        message: The debug message to display.
    """
    console.print(f"[dim]🔧 {message}[/dim]")
