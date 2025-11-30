"""
Progress indicators and spinners for long-running operations.

https://rich.readthedocs.io/en/latest/progress.html
"""

from contextlib import contextmanager
from typing import Generator

from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TaskProgressColumn,
    TextColumn,
    TimeRemainingColumn,
)
from rich.status import Status

from src.ui.console import console


def create_spinner_progress() -> Progress:
    """
    Create a simple spinner progress for indeterminate operations.

    Returns:
        Progress: Configured progress bar with spinner.
    """
    return Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    )


def create_bar_progress() -> Progress:
    """
    Create a progress bar for determinate operations with percentage.

    Returns:
        Progress: Configured progress bar with percentage and time remaining.
    """
    return Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TaskProgressColumn(),
        TimeRemainingColumn(),
        console=console,
    )


@contextmanager
def spinner(message: str) -> Generator[Status, None, None]:
    """
    Context manager for displaying a spinner during an operation.

    Args:
        message: The message to display next to the spinner.

    Yields:
        Status: The Rich status object.

    Example:
        with spinner("Connecting to server..."):
            ssh.connect()
    """
    with console.status(f"[bold blue]{message}[/bold blue]") as status:
        yield status
