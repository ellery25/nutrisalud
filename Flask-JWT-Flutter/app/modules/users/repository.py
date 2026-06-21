"""Data access for users. Routes/services never query the ORM directly."""

from ...extensions import db
from .models import User


class UserRepository:
    @staticmethod
    def by_id(user_id: str) -> User | None:
        return db.session.get(User, user_id)

    @staticmethod
    def by_username(username: str) -> User | None:
        return db.session.execute(
            db.select(User).filter_by(username=username)
        ).scalar_one_or_none()

    @staticmethod
    def paginate(page: int, per_page: int):
        return db.paginate(
            db.select(User).order_by(User.created_at.desc()),
            page=page,
            per_page=per_page,
            error_out=False,
        )

    @staticmethod
    def add(user: User) -> User:
        db.session.add(user)
        db.session.commit()
        return user

    @staticmethod
    def save() -> None:
        db.session.commit()

    @staticmethod
    def delete(user: User) -> None:
        db.session.delete(user)
        db.session.commit()
