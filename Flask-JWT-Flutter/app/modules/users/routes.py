from flask import Blueprint
from flask_jwt_extended import jwt_required

from ...core.responses import ok, paginated
from ...core.security import ROLE_ADMIN, require_roles
from ...core.validation import pagination_params, validate_body
from .repository import UserRepository
from .schemas import ChangePasswordSchema, UpdateUserSchema
from .service import UserService

users_bp = Blueprint("users", __name__)


@users_bp.get("")
@require_roles(ROLE_ADMIN)  # user enumeration is admin-only since 2.0
def list_users():
    page, per_page = pagination_params()
    result = UserRepository.paginate(page, per_page)
    return paginated([u.profile_dict() for u in result.items], result)


@users_bp.get("/<user_id>")
@jwt_required()
def get_user(user_id: str):
    # Public projection only — no credentials, no role leakage.
    return ok(UserService.get_or_404(user_id).public_dict())


@users_bp.put("/<user_id>")
@jwt_required()
@validate_body(UpdateUserSchema())
def update_user(user_id: str, body: dict):
    return ok(UserService.update(user_id, body).public_dict(), "User updated")


@users_bp.put("/<user_id>/password")
@jwt_required()
@validate_body(ChangePasswordSchema())
def change_password(user_id: str, body: dict):
    UserService.change_password(
        user_id, body["current_password"], body["new_password"]
    )
    return ok(message="Password updated")


@users_bp.delete("/<user_id>")
@jwt_required()
def delete_user(user_id: str):
    UserService.delete(user_id)
    return ok(message="Account deleted")
