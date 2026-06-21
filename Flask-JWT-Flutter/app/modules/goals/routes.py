from flask import Blueprint

from ...core.responses import created, ok
from ...core.security import ROLE_USER, current_identity, require_roles
from ...core.validation import validate_body
from .schemas import CheckInSchema, CreateGoalSchema
from .service import GoalService

goals_bp = Blueprint("goals", __name__)


@goals_bp.get("")
@require_roles(ROLE_USER)
def list_goals():
    # Unpaginated: a user's goal count is bounded by the UX.
    return ok(GoalService.list_goals(current_identity()))


@goals_bp.post("")
@require_roles(ROLE_USER)
@validate_body(CreateGoalSchema())
def create_goal(body: dict):
    goal = GoalService.create(current_identity(), body)
    return created(goal.to_dict(today_count=0, last7=[0] * 7), "Goal created")


@goals_bp.delete("/<goal_id>")
@require_roles(ROLE_USER)
def delete_goal(goal_id: str):
    GoalService.delete(goal_id, current_identity())
    return ok(message="Goal deleted")


@goals_bp.post("/<goal_id>/check-in")
@require_roles(ROLE_USER)
@validate_body(CheckInSchema())
def check_in(goal_id: str, body: dict):
    result = GoalService.check_in(current_identity(), goal_id, body["delta"])
    return ok(result, "Checked in")
