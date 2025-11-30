"""
Fachada principal de servicios.
Expone los servicios más utilizados para facilitar su importación.
"""

# Core
# Connectivity
from .connectivity.ssh_client import CommandResult, SSHService
from .connectivity.system_check import (
    SoftwareInfo,
    SystemCheckResult,
    SystemCheckService,
)
from .core.copier_wrapper import generate_project, update_project

__all__ = [
    "generate_project",
    "update_project",
    "SSHService",
    "CommandResult",
    "SystemCheckService",
    "SystemCheckResult",
    "SoftwareInfo",
]
