"""
CLI Configuration using Pydantic Settings.
https://docs.pydantic.dev/latest/concepts/pydantic_settings/
"""

from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # Nexus Registry
    nexus_user: str = "edugonmor_nexus_user"
    nexus_password: str = "edugonmor_nexus_password"
    nexus_registry: str = "nexus.edugonmor.com/repository/docker-hosted"

    # CLI defaults
    default_template_path: Path = Path("/app/template")
    workspace_path: Path = Path("/workspace")


settings = Settings()
