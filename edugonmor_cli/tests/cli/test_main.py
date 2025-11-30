"""
Tests for the main CLI application.

Verifica el funcionamiento de los comandos CLI principales,
incluyendo ayuda, comandos locales y validación de sesión.

https://typer.tiangolo.com/tutorial/testing/
"""

from typer.testing import CliRunner

from src.main import app

runner = CliRunner()


# =============================================================================
# 📡 TESTS DE AYUDA Y ESTRUCTURA
# =============================================================================


def test_app_help():
    """
    Test that the CLI shows help correctly.

    Verifica que el comando --help funciona y muestra información básica.
    """
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    assert "edugonmor" in result.stdout.lower() or "cli" in result.stdout.lower()


def test_app_help_no_remote_commands_without_session():
    """
    Test that all commands are shown in help.

    Ahora todos los comandos están siempre registrados,
    la validación de sesión se hace en runtime.
    """
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    # All commands should appear (validation is at runtime now)
    assert "connect" in result.stdout.lower()
    assert "status" in result.stdout.lower()
    assert "version" in result.stdout.lower()
    # Remote commands are now always visible
    assert "create" in result.stdout.lower()
    assert "system-info" in result.stdout.lower()


# =============================================================================
# 📦 TESTS DE COMANDOS LOCALES (No requieren SSH)
# =============================================================================


def test_list_templates():
    """
    Test that the templates command works.

    El comando 'templates' lista las plantillas disponibles localmente.
    """
    result = runner.invoke(app, ["templates"])
    assert result.exit_code == 0


def test_version():
    """
    Test that the version command works without SSH.

    El comando 'version' muestra la versión del CLI.
    """
    result = runner.invoke(app, ["version"])
    assert result.exit_code == 0


def test_status():
    """
    Test that status command works without SSH.

    El comando 'status' muestra el estado de conexión actual.
    """
    result = runner.invoke(app, ["status"])
    assert result.exit_code == 0


def test_config():
    """
    Test that the config command works without SSH.

    El comando 'config' muestra la configuración actual del CLI.
    """
    result = runner.invoke(app, ["config"])
    assert result.exit_code == 0


def test_template_info_without_name():
    """
    Test that template-info requires a template name argument.

    El comando 'template-info' requiere un argumento obligatorio.
    """
    result = runner.invoke(app, ["template-info"])
    # Should fail because NAME argument is required
    assert result.exit_code != 0


def test_disconnect_without_session():
    """
    Test that disconnect works gracefully without active session.

    El comando 'disconnect' debe funcionar aunque no haya sesión activa.
    """
    result = runner.invoke(app, ["disconnect"])
    # Should work (just shows "no session" message)
    assert result.exit_code == 0


# =============================================================================
# 📡 TESTS DE CONEXIÓN SSH (Validación de requisitos)
# =============================================================================


def test_connect_requires_host():
    """
    Test that connect command requires --host option.

    El comando 'connect' requiere las opciones --host y --user.
    """
    result = runner.invoke(app, ["connect"])
    # Should fail because --host is required
    assert result.exit_code != 0
    # Typer outputs error messages to stdout/stderr combined in output
    combined_output = (result.stdout + (result.output or "")).lower()
    has_error_message = "host" in combined_output or "missing" in combined_output
    assert has_error_message or result.exit_code == 2


def test_connect_help_shows_password_option():
    """
    Test that connect --help shows the --password option.

    El comando 'connect' debe mostrar la opción --password en la ayuda.
    """
    result = runner.invoke(app, ["connect", "--help"])
    assert result.exit_code == 0
    assert "--password" in result.stdout or "-p" in result.stdout
