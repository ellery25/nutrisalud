"""Data access for community posts. Routes/services never query the ORM directly."""

from sqlalchemy.orm import joinedload

from ...extensions import db
from .models import Comment


class CommentRepository:
    @staticmethod
    def by_id(comment_id: str) -> Comment | None:
        return db.session.get(Comment, comment_id)

    @staticmethod
    def paginate(page: int, per_page: int):
        # Eager-load authors to avoid N+1 when serializing the page.
        return db.paginate(
            db.select(Comment)
            .options(joinedload(Comment.author))
            .order_by(Comment.timestamp.desc()),
            page=page,
            per_page=per_page,
            error_out=False,
        )

    @staticmethod
    def add(comment: Comment) -> Comment:
        db.session.add(comment)
        db.session.commit()
        return comment

    @staticmethod
    def save() -> None:
        db.session.commit()

    @staticmethod
    def delete(comment: Comment) -> None:
        db.session.delete(comment)
        db.session.commit()
