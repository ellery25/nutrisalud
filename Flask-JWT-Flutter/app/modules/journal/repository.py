"""Data access for journal entries. Every query is owner-scoped."""

from datetime import datetime

from ...extensions import db
from .models import JournalEntry


class JournalRepository:
    @staticmethod
    def paginate_for_user(
        user_id: str,
        page: int,
        per_page: int,
        date_from: datetime | None = None,
        date_to: datetime | None = None,
    ):
        query = db.select(JournalEntry).filter_by(user_id=user_id)
        if date_from is not None:
            query = query.filter(JournalEntry.logged_at >= date_from)
        if date_to is not None:
            query = query.filter(JournalEntry.logged_at <= date_to)
        return db.paginate(
            query.order_by(JournalEntry.logged_at.desc()),
            page=page,
            per_page=per_page,
            error_out=False,
        )

    @staticmethod
    def by_id_for_user(entry_id: str, user_id: str) -> JournalEntry | None:
        return db.session.execute(
            db.select(JournalEntry).filter_by(id=entry_id, user_id=user_id)
        ).scalar_one_or_none()

    @staticmethod
    def entries_since(user_id: str, since_dt: datetime) -> list[JournalEntry]:
        return list(
            db.session.execute(
                db.select(JournalEntry)
                .filter_by(user_id=user_id)
                .filter(JournalEntry.logged_at >= since_dt)
            ).scalars()
        )

    @staticmethod
    def add(entry: JournalEntry) -> JournalEntry:
        db.session.add(entry)
        db.session.commit()
        return entry

    @staticmethod
    def delete(entry: JournalEntry) -> None:
        db.session.delete(entry)
        db.session.commit()
