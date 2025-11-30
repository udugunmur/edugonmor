"""
System commands package.
Commands for system utilities, version info, and configuration.

https://typer.tiangolo.com/tutorial/subcommands/
"""

from .config import show_config
from .version import version

__all__ = ["version", "show_config"]
