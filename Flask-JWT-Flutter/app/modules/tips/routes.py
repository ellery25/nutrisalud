from flask import Blueprint
from flask_jwt_extended import get_jwt_identity, jwt_required

from ...core.responses import created, ok, paginated
from ...core.security import ROLE_NUTRITIONIST, require_roles
from ...core.validation import pagination_params, validate_body
from .repository import TipRepository
from .schemas import CreateTipSchema, UpdateTipSchema
from .service import TipService

tips_bp = Blueprint("tips", __name__)


@tips_bp.get("")
@jwt_required()
def list_tips():
    page, per_page = pagination_params()
    result = TipRepository.paginate(page, per_page)
    return paginated([t.to_dict() for t in result.items], result)


@tips_bp.get("/<tip_id>")
@jwt_required()
def get_tip(tip_id: str):
    return ok(TipService.get_or_404(tip_id).to_dict())


@tips_bp.post("")
@require_roles(ROLE_NUTRITIONIST)
@validate_body(CreateTipSchema())
def create_tip(body: dict):
    # Author always comes from the token, never from the body.
    tip = TipService.create(get_jwt_identity(), body["title"], body["content"])
    return created(tip.to_dict(), "Tip created")


@tips_bp.put("/<tip_id>")
@jwt_required()
@validate_body(UpdateTipSchema())
def update_tip(tip_id: str, body: dict):
    return ok(TipService.update(tip_id, body).to_dict(), "Tip updated")


@tips_bp.delete("/<tip_id>")
@jwt_required()
def delete_tip(tip_id: str):
    TipService.delete(tip_id)
    return ok(message="Tip deleted")
