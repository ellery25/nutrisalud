from datetime import date

from flask import Blueprint, request

from ...core.errors import ApiError
from ...core.responses import created, ok, paginated
from ...core.security import ROLE_USER, current_identity, require_roles
from ...core.validation import pagination_params, validate_body
from .schemas import CreateJournalEntrySchema
from .service import JournalService

journal_bp = Blueprint("journal", __name__)


def _date_arg(name: str) -> date | None:
    raw = request.args.get(name)
    if raw is None:
        return None
    try:
        return date.fromisoformat(raw)
    except ValueError:
        raise ApiError(f"Invalid '{name}' date, expected YYYY-MM-DD") from None


@journal_bp.get("/entries")
@require_roles(ROLE_USER)
def list_entries():
    page, per_page = pagination_params()
    result = JournalService.list_entries(
        current_identity(), page, per_page, _date_arg("from"), _date_arg("to")
    )
    return paginated([e.to_dict() for e in result.items], result)


@journal_bp.post("/entries")
@require_roles(ROLE_USER)
@validate_body(CreateJournalEntrySchema())
def create_entry(body: dict):
    entry = JournalService.create(current_identity(), body)
    return created(entry.to_dict(), "Entry created")


@journal_bp.delete("/entries/<entry_id>")
@require_roles(ROLE_USER)
def delete_entry(entry_id: str):
    JournalService.delete(entry_id, current_identity())
    return ok(message="Entry deleted")


@journal_bp.get("/stats/weekly")
@require_roles(ROLE_USER)
def weekly_stats():
    return ok(JournalService.weekly_stats(current_identity()))
