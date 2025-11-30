"""
Composite UI panels package.
Contains complex, multi-component visual elements.
"""

from .status import (
    print_connection_status,
    print_operation_status,
    print_system_info_panel,
)

__all__ = [
    "print_connection_status",
    "print_operation_status",
    "print_system_info_panel",
]
