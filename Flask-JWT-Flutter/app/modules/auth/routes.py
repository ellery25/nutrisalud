from flask import Blueprint
from flask_jwt_extended import get_jwt_identity, jwt_required

from ...core.responses import created, ok
from ...core.validation import validate_body
from ...extensions import limiter
from ..users.service import UserService
from .schemas import LoginSchema, RegisterSchema
from .service import AuthService

auth_bp = Blueprint("auth", __name__)


@auth_bp.post("/login")
@limiter.limit("10 per minute")  # brute-force protection
@validate_body(LoginSchema())
def login(body: dict):
    return ok(AuthService.login(body["username"], body["password"]), "Logged in")


@auth_bp.post("/register")
@limiter.limit("5 per minute")
@validate_body(RegisterSchema())
def register(body: dict):
    user = AuthService.register(body["name"], body["username"], body["password"])
    return created(user.public_dict(), "Account created")


@auth_bp.post("/refresh")
@jwt_required(refresh=True)
def refresh():
    return ok(
        AuthService.rotate_refresh_token(get_jwt_identity()), "Token refreshed"
    )


@auth_bp.post("/logout")
@jwt_required(refresh=True)
def logout():
    AuthService.revoke_current_token()
    return ok(message="Logged out")


@auth_bp.get("/me")
@jwt_required()
def me():
    return ok(UserService.get_or_404(get_jwt_identity()).profile_dict())
