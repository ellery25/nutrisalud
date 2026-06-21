"""Standard response envelope (Phase 7 — API standardization).

Success: {"success": true,  "message": str, "data": ...}
Failure: {"success": false, "message": str, "errors": [...]}
"""

from flask import jsonify


def ok(data=None, message: str = "OK", status: int = 200):
    return jsonify({"success": True, "message": message, "data": data}), status


def created(data=None, message: str = "Created"):
    return ok(data, message, 201)


def fail(message: str, errors: list | None = None, status: int = 400):
    return (
        jsonify({"success": False, "message": message, "errors": errors or []}),
        status,
    )


def paginated(items: list, page, message: str = "OK"):
    """Wrap a Flask-SQLAlchemy pagination object."""
    return ok(
        {
            "items": items,
            "meta": {
                "page": page.page,
                "per_page": page.per_page,
                "total": page.total,
                "pages": page.pages,
            },
        },
        message,
    )
