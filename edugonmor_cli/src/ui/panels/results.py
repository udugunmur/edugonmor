"""
Result panels for displaying operation outcomes.

https://rich.readthedocs.io/en/latest/panel.html
"""

from typing import List, Optional

from rich.panel import Panel
from rich.syntax import Syntax
from rich.text import Text

from src.ui.console import console


def print_command_result(
    command: str,
    output: str,
    success: bool,
    error: Optional[str] = None,
) -> None:
    """
    Display the result of a remote command execution.

    Args:
        command: The command that was executed.
        output: The stdout from the command.
        success: Whether the command succeeded.
        error: Optional stderr output.
    """
    border_style = "green" if success else "red"
    icon = "✓" if success else "✗"

    content = Text()
    content.append("Command: ", style="bold")
    content.append(f"{command}\n\n", style="cyan")

    if output:
        content.append("Output:\n", style="bold")
        content.append(output)

    if error:
        content.append("\n\nError:\n", style="bold red")
        content.append(error, style="red")

    panel = Panel(
        content,
        title=f"[{border_style}]{icon}[/{border_style}] Command Result",
        border_style=border_style,
    )
    console.print(panel)


def print_file_list(
    title: str,
    files: List[str],
    icon: str = "📄",
) -> None:
    """
    Display a list of files in a formatted panel.

    Args:
        title: Panel title.
        files: List of file paths to display.
        icon: Icon to show before each file.
    """
    content = Text()
    for file in files:
        content.append(f"{icon} {file}\n")

    panel = Panel(
        content,
        title=title,
        border_style="blue",
    )
    console.print(panel)


def print_code_block(
    code: str,
    language: str = "python",
    title: Optional[str] = None,
) -> None:
    """
    Display a syntax-highlighted code block.

    Args:
        code: The code to display.
        language: Programming language for syntax highlighting.
        title: Optional title for the panel.
    """
    syntax = Syntax(code, language, theme="monokai", line_numbers=True)

    if title:
        panel = Panel(syntax, title=title, border_style="blue")
        console.print(panel)
    else:
        console.print(syntax)
