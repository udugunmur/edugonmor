"""Tests for the Copier template generation."""

import tempfile
from pathlib import Path

import pytest


@pytest.fixture
def temp_output_dir():
    """Create a temporary directory for test outputs."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


def test_template_exists():
    """Test that the template directory exists."""
    template_path = Path("template")
    assert template_path.exists(), "Template directory should exist"


def test_copier_config_exists():
    """Test that copier.yml exists in template."""
    copier_config = Path("template/copier.yml")
    assert copier_config.exists(), "copier.yml should exist in template"
