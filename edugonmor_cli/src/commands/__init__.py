"""
Commands facade.
Exposes CLI commands organized by business domain.

This module serves as the public API for all CLI commands.
Import commands from here, not from submodules directly.

https://typer.tiangolo.com/tutorial/subcommands/
"""

# Connectivity Domain
from .connectivity import connect, disconnect, status, system_info

# Project Domain
from .project import create, update

# System Domain
from .system import show_config, version
from .templates import info as template_info

# Templates Domain
from .templates import list_templates

__all__ = [
    # Connectivity
    "connect",
    "disconnect",
    "status",
    "system_info",
    # Project
    "create",
    "update",
    # Templates
    "list_templates",
    "template_info",
    # System
    "version",
    "show_config",
]
