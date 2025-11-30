"""
UI components using Rich.
Provides a facade for the most commonly used UI functions.

https://rich.readthedocs.io/en/latest/
"""

# Console singleton
# Messages (most used)
from .components.messages import (
    print_debug,
    print_error,
    print_info,
    print_success,
    print_warning,
)

# Progress indicators
from .components.progress import (
    create_bar_progress,
    create_spinner_progress,
    spinner,
)

# Tables
from .components.tables import (
    create_table,
    print_dict_table,
    print_table,
)
from .console import console

# Prompts
from .prompts.inputs import (
    ask,
    ask_int,
    choose,
    confirm,
)

# Themes
from .themes.colors import (
    COLORS,
    ICONS,
    STYLES,
    get_status_icon,
    get_status_style,
)

__all__ = [
    # Console
    "console",
    # Messages
    "print_success",
    "print_error",
    "print_warning",
    "print_info",
    "print_debug",
    # Progress
    "create_spinner_progress",
    "create_bar_progress",
    "spinner",
    # Tables
    "create_table",
    "print_table",
    "print_dict_table",
    # Prompts
    "ask",
    "ask_int",
    "confirm",
    "choose",
    # Themes
    "COLORS",
    "STYLES",
    "ICONS",
    "get_status_style",
    "get_status_icon",
]
