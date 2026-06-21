"""Data access for professional tips. Routes/services never query the ORM directly."""

from sqlalchemy.orm import joinedload

from ...extensions import db
from .models import ProfessionalTip


class TipRepository:
    @staticmethod
    def by_id(tip_id: str) -> ProfessionalTip | None:
        return db.session.get(ProfessionalTip, tip_id)

    @staticmethod
    def paginate(page: int, per_page: int):
        # Eager-load authors to avoid N+1 when serializing the page.
        return db.paginate(
            db.select(ProfessionalTip)
            .options(joinedload(ProfessionalTip.nutritionist))
            .order_by(ProfessionalTip.created_at.desc()),
            page=page,
            per_page=per_page,
            error_out=False,
        )

    @staticmethod
    def add(tip: ProfessionalTip) -> ProfessionalTip:
        db.session.add(tip)
        db.session.commit()
        return tip

    @staticmethod
    def save() -> None:
        db.session.commit()

    @staticmethod
    def delete(tip: ProfessionalTip) -> None:
        db.session.delete(tip)
        db.session.commit()
