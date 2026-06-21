"""Application errors and global handlers.

Every error leaves the API as the standard failure envelope; raw stack
traces never reach clients.
"""

import logging

from marshmallow import ValidationError
from sqlalchemy.exc import IntegrityError
from werkzeug.exceptions import HTTPException

from .responses import fail

logger = logging.getLogger("nutrisalud.errors")


class ApiError(Exception):
    """Raise anywhere in a service/route; the global handler formats it."""

    def __init__(self, message: str, status: int = 400, errors: list | None = None):
        super().__init__(message)
        self.message = message
        self.status = status
        self.errors = errors or []


class NotFoundError(ApiError):
    def __init__(self, resource: str, resource_id: str):
        super().__init__(f"{resource} not found: {resource_id}", status=404)


class ForbiddenError(ApiError):
    def __init__(self, message: str = "You do not have access to this resource"):
        super().__init__(message, status=403)


class UnauthorizedError(ApiError):
    def __init__(self, message: str = "Invalid credentials"):
        super().__init__(message, status=401)


def register_error_handlers(app):
    @app.errorhandler(ApiError)
    def handle_api_error(error: ApiError):
        return fail(error.message, error.errors, error.status)

    @app.errorhandler(ValidationError)
    def handle_validation_error(error: ValidationError):
        errors = [
            {"field": field, "messages": messages}
            for field, messages in error.normalized_messages().items()
        ]
        return fail("Validation error", errors, 422)

    @app.errorhandler(IntegrityError)
    def handle_integrity_error(error: IntegrityError):
        from ..extensions import db

        db.session.rollback()
        logger.warning("integrity_error", exc_info=error)
        return fail("A record with these unique values already exists", status=409)

    @app.errorhandler(HTTPException)
    def handle_http_exception(error: HTTPException):
        return fail(error.description or error.name, status=error.code or 500)

    @app.errorhandler(Exception)
    def handle_unexpected(error: Exception):
        logger.exception("unhandled_exception")
        return fail("Internal server error", status=500)
