"""
Table utilities for structured data display.

https://rich.readthedocs.io/en/latest/tables.html
"""

from typing import Any, Dict, List

from rich.table import Table

from src.ui.console import console


def create_table(
    title: str,
    columns: List[str],
    rows: List[List[Any]],
    show_header: bool = True,
    show_lines: bool = False,
) -> Table:
    """
    Create a formatted table with the given data.

    Args:
        title: The table title.
        columns: List of column headers.
        rows: List of row data (each row is a list of values).
        show_header: Whether to display column headers.
        show_lines: Whether to show row separator lines.

    Returns:
        Table: Configured Rich table object.
    """
    table = Table(
        title=title,
        show_header=show_header,
        show_lines=show_lines,
    )

    for column in columns:
        table.add_column(column, style="cyan")

    for row in rows:
        table.add_row(*[str(cell) for cell in row])

    return table


def print_table(
    title: str,
    columns: List[str],
    rows: List[List[Any]],
    show_header: bool = True,
) -> None:
    """
    Create and immediately print a table.

    Args:
        title: The table title.
        columns: List of column headers.
        rows: List of row data.
        show_header: Whether to display column headers.
    """
    table = create_table(title, columns, rows, show_header)
    console.print(table)


def print_dict_table(title: str, data: Dict[str, Any]) -> None:
    """
    Print a dictionary as a two-column table (key-value).

    Args:
        title: The table title.
        data: Dictionary to display.
    """
    table = Table(title=title, show_header=True)
    table.add_column("Property", style="cyan")
    table.add_column("Value", style="green")

    for key, value in data.items():
        table.add_row(str(key), str(value))

    console.print(table)
