"""NutriSalud backend — application factory."""

from flask import Flask

from .core.config import get_config
from .core.errors import register_error_handlers
from .core.logging import configure_logging
from .core.responses import fail, ok
from .extensions import cors, db, jwt, limiter, migrate

API_PREFIX = "/api/v1"


def create_app(config_name: str | None = None) -> Flask:
    app = Flask(__name__)
    app.config.from_object(get_config(config_name))

    configure_logging(app)

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    cors.init_app(
        app,
        resources={r"/api/*": {"origins": app.config["CORS_ORIGINS"]}},
    )
    limiter.init_app(app)

    register_error_handlers(app)
    _register_jwt_callbacks()
    _register_blueprints(app)

    @app.get("/health")
    @limiter.exempt
    def health():
        return ok({"status": "healthy"})

    return app


def _register_blueprints(app: Flask) -> None:
    # Imported here so models register with SQLAlchemy exactly once.
    from .modules.auth.routes import auth_bp
    from .modules.community.routes import community_bp
    from .modules.goals.routes import goals_bp
    from .modules.journal.routes import journal_bp
    from .modules.notifications.routes import notifications_bp
    from .modules.nutritionists.routes import nutritionists_bp
    from .modules.tips.routes import tips_bp
    from .modules.users.routes import users_bp

    app.register_blueprint(auth_bp, url_prefix=f"{API_PREFIX}/auth")
    app.register_blueprint(users_bp, url_prefix=f"{API_PREFIX}/users")
    app.register_blueprint(nutritionists_bp, url_prefix=f"{API_PREFIX}/nutritionists")
    app.register_blueprint(community_bp, url_prefix=f"{API_PREFIX}/community")
    app.register_blueprint(tips_bp, url_prefix=f"{API_PREFIX}/tips")
    app.register_blueprint(journal_bp, url_prefix=f"{API_PREFIX}/journal")
    app.register_blueprint(goals_bp, url_prefix=f"{API_PREFIX}/goals")
    app.register_blueprint(
        notifications_bp, url_prefix=f"{API_PREFIX}/notifications"
    )


def _register_jwt_callbacks() -> None:
    from .modules.auth.service import AuthService

    @jwt.token_in_blocklist_loader
    def is_token_revoked(_header, payload) -> bool:
        return AuthService.is_revoked(payload["jti"])

    @jwt.expired_token_loader
    def expired(_header, _payload):
        return fail("Token has expired", status=401)

    @jwt.invalid_token_loader
    def invalid(reason):
        return fail(f"Invalid token: {reason}", status=401)

    @jwt.unauthorized_loader
    def missing(reason):
        return fail(f"Authorization required: {reason}", status=401)

    @jwt.revoked_token_loader
    def revoked(_header, _payload):
        return fail("Token has been revoked", status=401)
