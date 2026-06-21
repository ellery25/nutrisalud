"""Password hashing, RBAC and ownership checks (Phase 3 — security)."""

from functools import wraps

from flask_jwt_extended import get_jwt, get_jwt_identity, verify_jwt_in_request
from werkzeug.security import check_password_hash, generate_password_hash

from .errors import ForbiddenError

ROLE_USER = "user"
ROLE_NUTRITIONIST = "nutritionist"
ROLE_ADMIN = "admin"

_HASH_PREFIXES = ("pbkdf2:", "scrypt:")


def hash_password(plain: str) -> str:
    return generate_password_hash(plain)


def verify_password(stored: str, candidate: str) -> tuple[bool, bool]:
    """Returns (matches, needs_rehash).

    Legacy rows (pre-2.0) stored plaintext passwords. They are accepted
    once and transparently upgraded to a hash by the auth service.
    """
    if stored.startswith(_HASH_PREFIXES):
        return check_password_hash(stored, candidate), False
    return stored == candidate, stored == candidate


def current_identity() -> str:
    return get_jwt_identity()


def current_role() -> str:
    return get_jwt().get("role", ROLE_USER)


def require_roles(*roles: str):
    """Route decorator: valid JWT + one of the given roles (admin always passes)."""

    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            verify_jwt_in_request()
            role = current_role()
            if role != ROLE_ADMIN and role not in roles:
                raise ForbiddenError("Insufficient permissions")
            return fn(*args, **kwargs)

        return wrapper

    return decorator


def ensure_owner(owner_id: str) -> None:
    """Resource mutation guard: caller must own the resource (or be admin)."""
    if current_role() == ROLE_ADMIN:
        return
    if get_jwt_identity() != owner_id:
        raise ForbiddenError()
