"""
Basic input prompts for user interaction.

https://rich.readthedocs.io/en/latest/prompt.html
"""

from typing import List, Optional

from rich.prompt import Confirm, IntPrompt, Prompt

from src.ui.console import console


def ask(
    question: str,
    default: Optional[str] = None,
    password: bool = False,
) -> str:
    """
    Ask the user for text input.

    Args:
        question: The question to display.
        default: Default value if user presses Enter.
        password: Whether to hide input (for passwords).

    Returns:
        str: The user's input.
    """
    return Prompt.ask(
        f"[bold cyan]{question}[/bold cyan]",
        default=default,
        password=password,
        console=console,
    )


def ask_int(
    question: str,
    default: Optional[int] = None,
    min_value: Optional[int] = None,
    max_value: Optional[int] = None,
) -> int:
    """
    Ask the user for an integer input with optional validation.

    Args:
        question: The question to display.
        default: Default value if user presses Enter.
        min_value: Minimum acceptable value.
        max_value: Maximum acceptable value.

    Returns:
        int: The user's integer input.
    """
    while True:
        value = IntPrompt.ask(
            f"[bold cyan]{question}[/bold cyan]",
            default=default,
            console=console,
        )

        if min_value is not None and value < min_value:
            console.print(f"[red]Value must be at least {min_value}[/red]")
            continue

        if max_value is not None and value > max_value:
            console.print(f"[red]Value must be at most {max_value}[/red]")
            continue

        return value


def confirm(question: str, default: bool = False) -> bool:
    """
    Ask the user for a yes/no confirmation.

    Args:
        question: The question to display.
        default: Default value if user presses Enter.

    Returns:
        bool: True if user confirmed, False otherwise.
    """
    return Confirm.ask(
        f"[bold cyan]{question}[/bold cyan]",
        default=default,
        console=console,
    )


def choose(
    question: str,
    choices: List[str],
    default: Optional[str] = None,
) -> str:
    """
    Ask the user to choose from a list of options.

    Args:
        question: The question to display.
        choices: List of valid choices.
        default: Default choice if user presses Enter.

    Returns:
        str: The user's choice.
    """
    choices_str = "/".join(choices)
    return Prompt.ask(
        f"[bold cyan]{question}[/bold cyan] [{choices_str}]",
        choices=choices,
        default=default,
        console=console,
    )
