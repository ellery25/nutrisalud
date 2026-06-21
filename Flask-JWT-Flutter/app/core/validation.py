"""Request validation via marshmallow schemas.

Unknown fields are rejected (mass-assignment protection); validation
failures surface as the standard 422 envelope through the global handler.
"""

from functools import wraps

from flask import request
from marshmallow import Schema, ValidationError


def validate_body(schema: Schema):
    """Decorator: parse+validate the JSON body, inject as `body` kwarg."""

    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            payload = request.get_json(silent=True)
            if payload is None:
                raise ValidationError({"_body": ["Expected a JSON body"]})
            kwargs["body"] = schema.load(payload)
            return fn(*args, **kwargs)

        return wrapper

    return decorator


def pagination_params(max_per_page: int = 50) -> tuple[int, int]:
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 20, type=int)
    return max(page, 1), min(max(per_page, 1), max_per_page)
