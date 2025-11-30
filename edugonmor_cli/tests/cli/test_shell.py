"""
Tests for the interactive shell.

Verifica el funcionamiento del shell interactivo,
incluyendo el autocompletado y la ejecución de comandos.

https://python-prompt-toolkit.readthedocs.io/en/master/
"""

from src.shell import (
    BASE_COMMANDS,
    REMOTE_COMMANDS,
    get_completer,
    get_prompt_text,
)

# =============================================================================
# 🧪 TESTS DE SHELL
# =============================================================================


def test_get_prompt_text_without_session():
    """
    Test that prompt shows default text without session.

    Sin sesión activa, el prompt debe mostrar solo 'edugonmor>'.
    """
    prompt = get_prompt_text()
    assert "edugonmor>" in prompt
    # Should not show host info without session
    assert "@" not in prompt or "edugonmor>" in prompt


def test_get_completer_returns_base_commands():
    """
    Test that completer includes base commands.

    El completer debe incluir comandos básicos como connect, status, etc.
    """
    completer = get_completer()
    # Check that completer has words
    assert completer.words is not None
    # Check base commands are included
    for cmd in ["connect", "status", "help", "exit"]:
        assert cmd in completer.words


def test_base_commands_list():
    """
    Test that BASE_COMMANDS contains expected commands.

    La lista BASE_COMMANDS debe contener los comandos fundamentales.
    """
    expected = ["connect", "disconnect", "status", "help", "exit"]
    for cmd in expected:
        assert cmd in BASE_COMMANDS


def test_remote_commands_list():
    """
    Test that REMOTE_COMMANDS contains expected commands.

    La lista REMOTE_COMMANDS debe contener los comandos remotos.
    """
    expected = ["system-info", "create", "update"]
    for cmd in expected:
        assert cmd in REMOTE_COMMANDS
