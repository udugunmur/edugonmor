"""
Standard color palette and style definitions.

https://rich.readthedocs.io/en/latest/style.html
"""

from typing import Dict

# Brand colors for consistent styling across the CLI
COLORS: Dict[str, str] = {
    # Status colors
    "success": "green",
    "error": "red",
    "warning": "yellow",
    "info": "blue",
    # UI element colors
    "primary": "cyan",
    "secondary": "magenta",
    "muted": "dim",
    # Semantic colors
    "highlight": "bold cyan",
    "danger": "bold red",
    "safe": "bold green",
}

# Pre-defined styles for common elements
STYLES: Dict[str, str] = {
    # Messages
    "success_msg": "bold green",
    "error_msg": "bold red",
    "warning_msg": "bold yellow",
    "info_msg": "bold blue",
    # UI elements
    "header": "bold cyan underline",
    "subheader": "bold white",
    "label": "cyan",
    "value": "white",
    # Status indicators
    "connected": "bold green",
    "disconnected": "bold red",
    "pending": "bold yellow",
}

# Icons for consistent visual language
ICONS: Dict[str, str] = {
    "success": "✓",
    "error": "✗",
    "warning": "⚠",
    "info": "ℹ",
    "debug": "🔧",
    "folder": "📁",
    "file": "📄",
    "connection": "🔌",
    "lock": "🔐",
    "rocket": "🚀",
    "package": "📦",
    "gear": "⚙️",
}


def get_status_style(success: bool) -> str:
    """
    Get the appropriate style for a success/failure status.

    Args:
        success: Whether the status is successful.

    Returns:
        str: The Rich style string.
    """
    return STYLES["success_msg"] if success else STYLES["error_msg"]


def get_status_icon(success: bool) -> str:
    """
    Get the appropriate icon for a success/failure status.

    Args:
        success: Whether the status is successful.

    Returns:
        str: The icon character.
    """
    return ICONS["success"] if success else ICONS["error"]
