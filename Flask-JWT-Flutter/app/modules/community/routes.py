from flask import Blueprint
from flask_jwt_extended import get_jwt_identity, jwt_required

from ...core.responses import created, ok, paginated
from ...core.security import ROLE_USER, require_roles
from ...core.validation import pagination_params, validate_body
from .repository import CommentRepository
from .schemas import CreateCommentSchema, UpdateCommentSchema
from .service import CommentService

community_bp = Blueprint("community", __name__)


@community_bp.get("/posts")
@jwt_required()
def list_posts():
    page, per_page = pagination_params()
    result = CommentRepository.paginate(page, per_page)
    return paginated([c.to_dict() for c in result.items], result)


@community_bp.post("/posts")
@require_roles(ROLE_USER)  # authorship FK targets the users table
@validate_body(CreateCommentSchema())
def create_post(body: dict):
    # Author always comes from the token, never from the body.
    comment = CommentService.create(
        get_jwt_identity(), body["content"], body.get("photo")
    )
    return created(comment.to_dict(), "Post created")


@community_bp.put("/posts/<post_id>")
@jwt_required()
@validate_body(UpdateCommentSchema())
def update_post(post_id: str, body: dict):
    return ok(CommentService.update(post_id, body).to_dict(), "Post updated")


@community_bp.delete("/posts/<post_id>")
@jwt_required()
def delete_post(post_id: str):
    CommentService.delete(post_id)
    return ok(message="Post deleted")
