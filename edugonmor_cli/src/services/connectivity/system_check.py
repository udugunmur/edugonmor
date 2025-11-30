"""
System check service for remote server diagnostics.

Provides functionality to verify installed software and user permissions
on a remote server via SSH. Works across Linux, macOS, and Windows (WSL).

https://docs.fabfile.org/en/stable/api/connection.html#fabric.connection.Connection.run
"""

from dataclasses import dataclass
from typing import Optional

from src.services.connectivity.ssh_client import SSHService


@dataclass
class SoftwareInfo:
    """Information about installed software."""

    name: str
    installed: bool
    version: Optional[str] = None
    error: Optional[str] = None


@dataclass
class SystemCheckResult:
    """Complete system check result."""

    python3: SoftwareInfo
    docker: SoftwareInfo
    docker_compose: SoftwareInfo
    has_sudo: bool
    sudo_error: Optional[str] = None
    os_type: Optional[str] = None


class SystemCheckService:
    """
    Service to check remote system configuration.

    Verifies software installation and user permissions on a remote server.
    Works across Linux, macOS, and Windows (WSL/Git Bash).

    Attributes:
        ssh (SSHService): The SSH connection to use for remote commands.
    """

    def __init__(self, ssh: SSHService):
        """
        Initialize the system check service.

        Args:
            ssh (SSHService): An established SSH connection.
        """
        self.ssh = ssh
        self._os_type: Optional[str] = None

    def detect_os(self) -> str:
        """
        Detect the remote operating system.

        Returns:
            str: 'macos', 'linux', or 'windows'
        """
        if self._os_type:
            return self._os_type

        # Try uname first (works on macOS and Linux)
        result = self.ssh.run_safe("uname -s 2>&1")

        if result.success and result.output:
            output = result.output.lower().strip()
            if "darwin" in output:
                self._os_type = "macos"
            elif "linux" in output:
                self._os_type = "linux"
            elif "mingw" in output or "msys" in output or "cygwin" in output:
                self._os_type = "windows"
            else:
                self._os_type = "unknown"
        else:
            # Fallback: check for Windows
            result = self.ssh.run_safe("echo %OS% 2>&1")
            if result.success and "windows" in result.output.lower():
                self._os_type = "windows"
            else:
                self._os_type = "unknown"

        return self._os_type

    def check_python3(self) -> SoftwareInfo:
        """
        Check if Python 3 is installed and get its version.

        Works across all platforms by trying multiple commands.

        Returns:
            SoftwareInfo: Python 3 installation information.
        """
        # Try python3 first (Linux/macOS standard)
        result = self.ssh.run_safe("python3 --version 2>&1")

        if result.success and result.output and "python" in result.output.lower():
            version = result.output.replace("Python ", "").strip()
            return SoftwareInfo(
                name="Python 3",
                installed=True,
                version=version,
            )

        # Try python (might be Python 3 on some systems)
        result = self.ssh.run_safe("python --version 2>&1")

        if result.success and result.output:
            output = result.output.strip()
            if "Python 3" in output:
                version = output.replace("Python ", "").strip()
                return SoftwareInfo(
                    name="Python 3",
                    installed=True,
                    version=version,
                )

        return SoftwareInfo(
            name="Python 3",
            installed=False,
            error="Python 3 not found",
        )

    def check_docker(self) -> SoftwareInfo:
        """
        Check if Docker is installed and get its version.

        Works across all platforms including Docker Desktop on macOS/Windows.
        Handles PATH issues in non-interactive SSH sessions.

        Returns:
            SoftwareInfo: Docker installation information.
        """
        # Common Docker paths for different platforms
        docker_paths = [
            "docker",  # Standard PATH
            "/usr/local/bin/docker",  # macOS/Linux common
            "/opt/homebrew/bin/docker",  # macOS Apple Silicon (Homebrew)
            # Docker Desktop macOS
            "/Applications/Docker.app/Contents/Resources/bin/docker",
            "$HOME/.docker/bin/docker",  # Docker Desktop alternative
        ]

        for docker_cmd in docker_paths:
            result = self.ssh.run_safe(f"{docker_cmd} --version 2>&1")

            if result.success and result.output and "docker" in result.output.lower():
                try:
                    output = result.output.strip()
                    if "version" in output.lower():
                        version = output.split("version")[1].split(",")[0].strip()
                        return SoftwareInfo(
                            name="Docker",
                            installed=True,
                            version=version,
                        )
                    return SoftwareInfo(
                        name="Docker",
                        installed=True,
                        version=output,
                    )
                except (IndexError, AttributeError):
                    return SoftwareInfo(
                        name="Docker",
                        installed=True,
                        version=result.output.strip(),
                    )

        # Try sourcing shell profile first (for PATH configuration)
        shell_cmd = (
            "source ~/.bashrc 2>/dev/null; "
            "source ~/.zshrc 2>/dev/null; "
            "source ~/.profile 2>/dev/null; "
            "docker --version 2>&1"
        )
        result = self.ssh.run_safe(shell_cmd)

        if result.success and result.output and "docker" in result.output.lower():
            try:
                output = result.output.strip()
                if "version" in output.lower():
                    version = output.split("version")[1].split(",")[0].strip()
                    return SoftwareInfo(
                        name="Docker",
                        installed=True,
                        version=version,
                    )
            except (IndexError, AttributeError):
                pass

        return SoftwareInfo(
            name="Docker",
            installed=False,
            error="Docker not found",
        )

    def check_docker_compose(self) -> SoftwareInfo:
        """
        Check if Docker Compose is installed and get its version.

        Checks both plugin syntax (docker compose) and standalone (docker-compose).
        Works across all platforms with PATH handling.

        Returns:
            SoftwareInfo: Docker Compose installation information.
        """
        # Common paths for docker-compose
        compose_paths = [
            "docker-compose",  # Standard PATH
            "/usr/local/bin/docker-compose",  # macOS/Linux common
            "/opt/homebrew/bin/docker-compose",  # macOS Apple Silicon
            "$HOME/.docker/bin/docker-compose",  # Docker Desktop
        ]

        # First try standalone docker-compose
        for compose_cmd in compose_paths:
            result = self.ssh.run_safe(f"{compose_cmd} --version 2>&1")

            if result.success and result.output and "version" in result.output.lower():
                try:
                    output = result.output.strip()
                    parts = output.lower().split("version")
                    if len(parts) > 1:
                        version = parts[1].strip().split()[0].strip().rstrip(",")
                        return SoftwareInfo(
                            name="Docker Compose",
                            installed=True,
                            version=version,
                        )
                    return SoftwareInfo(
                        name="Docker Compose",
                        installed=True,
                        version=output,
                    )
                except (IndexError, AttributeError):
                    return SoftwareInfo(
                        name="Docker Compose",
                        installed=True,
                        version=result.output.strip(),
                    )

        # Try with sourced profile
        shell_cmd = (
            "source ~/.bashrc 2>/dev/null; "
            "source ~/.zshrc 2>/dev/null; "
            "source ~/.profile 2>/dev/null; "
            "docker-compose --version 2>&1"
        )
        result = self.ssh.run_safe(shell_cmd)

        if result.success and result.output and "version" in result.output.lower():
            try:
                output = result.output.strip()
                parts = output.lower().split("version")
                if len(parts) > 1:
                    version = parts[1].strip().split()[0].strip().rstrip(",")
                    return SoftwareInfo(
                        name="Docker Compose",
                        installed=True,
                        version=version,
                    )
            except (IndexError, AttributeError):
                pass

        # Try plugin syntax (docker compose v2) with various paths
        docker_paths = [
            "docker",
            "/usr/local/bin/docker",
            "/opt/homebrew/bin/docker",
        ]

        for docker_cmd in docker_paths:
            result = self.ssh.run_safe(f"{docker_cmd} compose version 2>&1")

            if result.success and result.output and "version" in result.output.lower():
                try:
                    output = result.output.strip()
                    parts = output.lower().split("version")
                    if len(parts) > 1:
                        version = parts[1].strip().split()[0].strip()
                        return SoftwareInfo(
                            name="Docker Compose",
                            installed=True,
                            version=f"{version} (plugin)",
                        )
                except (IndexError, AttributeError):
                    pass

        return SoftwareInfo(
            name="Docker Compose",
            installed=False,
            error="Docker Compose not found",
        )

    def check_sudo_access(
        self, sudo_password: Optional[str] = None
    ) -> tuple[bool, Optional[str]]:
        """
        Check if the user has sudo privileges.

        Works across Linux and macOS. On Windows, checks for admin rights.

        Args:
            sudo_password (Optional[str]): The sudo password to test with.

        Returns:
            tuple[bool, Optional[str]]: (has_sudo, error_message)
        """
        os_type = self.detect_os()

        if os_type == "windows":
            # On Windows, check if running as admin
            result = self.ssh.run_safe("net session 2>&1")
            if result.success:
                return True, None
            return False, "Not running as Administrator"

        # Linux/macOS sudo check
        if sudo_password:
            # Use printf instead of echo for better compatibility
            # -S reads password from stdin, -v validates and extends timeout
            result = self.ssh.run_safe(
                f"printf '%s\\n' '{sudo_password}' | sudo -S -v 2>&1"
            )

            # Check for success indicators
            if result.success:
                # Verify it actually worked
                verify = self.ssh.run_safe("sudo -n true 2>&1")
                if verify.success:
                    return True, None
                # Password was accepted even if -n fails
                return True, None

            # Check output for common error messages
            output = result.output.lower() if result.output else ""
            error = result.error.lower() if result.error else ""
            combined = output + error

            if "incorrect password" in combined or "sorry" in combined:
                return False, "Incorrect sudo password"
            if "not in the sudoers" in combined:
                return False, "User not in sudoers file"

            return False, "Sudo authentication failed"

        # Test without password (NOPASSWD or cached credentials)
        result = self.ssh.run_safe("sudo -n true 2>&1")

        if result.success:
            return True, None

        return False, "Sudo requires password (use --sudo-password)"

    def run_full_check(self, sudo_password: Optional[str] = None) -> SystemCheckResult:
        """
        Run a complete system check.

        Args:
            sudo_password (Optional[str]): The sudo password to verify sudo access.

        Returns:
            SystemCheckResult: Complete system diagnostics.
        """
        os_type = self.detect_os()
        python3 = self.check_python3()
        docker = self.check_docker()
        docker_compose = self.check_docker_compose()
        has_sudo, sudo_error = self.check_sudo_access(sudo_password)

        return SystemCheckResult(
            python3=python3,
            docker=docker,
            docker_compose=docker_compose,
            has_sudo=has_sudo,
            sudo_error=sudo_error,
            os_type=os_type,
        )
