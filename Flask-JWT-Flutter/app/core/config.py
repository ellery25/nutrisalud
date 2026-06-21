"""Environment-driven configuration. No secrets in source control."""

import os
from datetime import timedelta


def _database_url(default: str) -> str:
    url = os.environ.get("DATABASE_URL", default)
    # Render/Heroku still hand out the deprecated scheme.
    if url.startswith("postgres://"):
        url = url.replace("postgres://", "postgresql://", 1)
    return url


class BaseConfig:
    SECRET_KEY = os.environ.get("SECRET_KEY")
    JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY")

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_pre_ping": True,  # survive dropped connections (Render sleeps)
        "pool_recycle": 280,
    }

    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=30)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    JWT_ERROR_MESSAGE_KEY = "message"

    # 3 MB: covers a recompressed base64 photo with headroom, blocks abuse.
    MAX_CONTENT_LENGTH = 3 * 1024 * 1024

    CORS_ORIGINS = [
        o.strip()
        for o in os.environ.get("CORS_ORIGINS", "*").split(",")
        if o.strip()
    ]

    RATELIMIT_STORAGE_URI = os.environ.get("REDIS_URL", "memory://")
    RATELIMIT_DEFAULT = "200 per minute"

    LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")
    JSON_LOGS = True


class DevelopmentConfig(BaseConfig):
    DEBUG = True
    JSON_LOGS = False
    SECRET_KEY = BaseConfig.SECRET_KEY or "dev-only-secret"
    JWT_SECRET_KEY = BaseConfig.JWT_SECRET_KEY or "dev-only-jwt-secret"
    SQLALCHEMY_DATABASE_URI = _database_url("sqlite:///nutrisalud_dev.db")


class TestingConfig(BaseConfig):
    TESTING = True
    SECRET_KEY = "test-secret"
    JWT_SECRET_KEY = "test-jwt-secret"
    SQLALCHEMY_DATABASE_URI = "sqlite://"  # in-memory
    SQLALCHEMY_ENGINE_OPTIONS = {}  # pooling options don't apply to sqlite memory
    RATELIMIT_ENABLED = False


class ProductionConfig(BaseConfig):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = _database_url("")

    @classmethod
    def validate(cls) -> None:
        """Fail fast instead of booting with insecure defaults."""
        missing = [
            name
            for name, value in (
                ("SECRET_KEY", cls.SECRET_KEY),
                ("JWT_SECRET_KEY", cls.JWT_SECRET_KEY),
                ("DATABASE_URL", cls.SQLALCHEMY_DATABASE_URI),
            )
            if not value
        ]
        if missing:
            raise RuntimeError(
                f"Refusing to start: missing required env vars {missing}"
            )


_CONFIGS = {
    "development": DevelopmentConfig,
    "testing": TestingConfig,
    "production": ProductionConfig,
}


def get_config(name: str | None = None):
    name = name or os.environ.get("FLASK_ENV", "development")
    config = _CONFIGS.get(name, DevelopmentConfig)
    if config is ProductionConfig:
        config.validate()
    return config
