from flask import Blueprint
from flask_jwt_extended import jwt_required

from ...core.responses import created, ok, paginated
from ...core.validation import pagination_params, validate_body
from ...extensions import limiter
from .repository import NutritionistRepository
from .schemas import RegisterNutritionistSchema, UpdateNutritionistSchema
from .service import NutritionistService

nutritionists_bp = Blueprint("nutritionists", __name__)


@nutritionists_bp.get("")
@jwt_required()
def list_nutritionists():
    page, per_page = pagination_params()
    result = NutritionistRepository.paginate(page, per_page)
    return paginated([n.public_dict() for n in result.items], result)


@nutritionists_bp.get("/<nutritionist_id>")
@jwt_required()
def get_nutritionist(nutritionist_id: str):
    return ok(NutritionistService.get_or_404(nutritionist_id).public_dict())


@nutritionists_bp.post("/register")
@limiter.limit("5 per minute")
@validate_body(RegisterNutritionistSchema())
def register(body: dict):
    nutritionist = NutritionistService.register(body)
    return created(nutritionist.public_dict(), "Account created")


@nutritionists_bp.put("/<nutritionist_id>")
@jwt_required()
@validate_body(UpdateNutritionistSchema())
def update_nutritionist(nutritionist_id: str, body: dict):
    return ok(
        NutritionistService.update(nutritionist_id, body).public_dict(),
        "Profile updated",
    )


@nutritionists_bp.delete("/<nutritionist_id>")
@jwt_required()
def delete_nutritionist(nutritionist_id: str):
    NutritionistService.delete(nutritionist_id)
    return ok(message="Account deleted")
