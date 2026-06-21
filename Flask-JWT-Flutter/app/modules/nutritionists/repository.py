"""Data access for nutritionists. Routes/services never query the ORM directly."""

from ...extensions import db
from .models import Nutritionist


class NutritionistRepository:
    @staticmethod
    def by_id(nutritionist_id: str) -> Nutritionist | None:
        return db.session.get(Nutritionist, nutritionist_id)

    @staticmethod
    def by_username(username: str) -> Nutritionist | None:
        return db.session.execute(
            db.select(Nutritionist).filter_by(username=username)
        ).scalar_one_or_none()

    @staticmethod
    def by_email(email: str) -> Nutritionist | None:
        return db.session.execute(
            db.select(Nutritionist).filter_by(email=email)
        ).scalar_one_or_none()

    @staticmethod
    def by_instagram(instagram: str) -> Nutritionist | None:
        return db.session.execute(
            db.select(Nutritionist).filter_by(instagram=instagram)
        ).scalar_one_or_none()

    @staticmethod
    def paginate(page: int, per_page: int):
        return db.paginate(
            db.select(Nutritionist).order_by(Nutritionist.rating.desc()),
            page=page,
            per_page=per_page,
            error_out=False,
        )

    @staticmethod
    def add(nutritionist: Nutritionist) -> Nutritionist:
        db.session.add(nutritionist)
        db.session.commit()
        return nutritionist

    @staticmethod
    def save() -> None:
        db.session.commit()

    @staticmethod
    def delete(nutritionist: Nutritionist) -> None:
        db.session.delete(nutritionist)
        db.session.commit()
