"""Data access for goals and check-ins. Every query is owner-scoped."""

from datetime import date

from ...extensions import db
from .models import Goal, GoalCheckIn


class GoalRepository:
    @staticmethod
    def goals_for_user(user_id: str) -> list[Goal]:
        return list(
            db.session.execute(
                db.select(Goal)
                .filter_by(user_id=user_id)
                .order_by(Goal.created_at)
            ).scalars()
        )

    @staticmethod
    def by_id_for_user(goal_id: str, user_id: str) -> Goal | None:
        return db.session.execute(
            db.select(Goal).filter_by(id=goal_id, user_id=user_id)
        ).scalar_one_or_none()

    @staticmethod
    def check_ins_between(
        goal_ids: list[str], from_day: date, to_day: date
    ) -> list[GoalCheckIn]:
        if not goal_ids:
            return []
        return list(
            db.session.execute(
                db.select(GoalCheckIn)
                .filter(GoalCheckIn.goal_id.in_(goal_ids))
                .filter(GoalCheckIn.day >= from_day, GoalCheckIn.day <= to_day)
            ).scalars()
        )

    @staticmethod
    def get_check_in(goal_id: str, day: date) -> GoalCheckIn | None:
        return db.session.execute(
            db.select(GoalCheckIn).filter_by(goal_id=goal_id, day=day)
        ).scalar_one_or_none()

    @staticmethod
    def add(instance) -> None:
        db.session.add(instance)
        db.session.commit()

    @staticmethod
    def delete(instance) -> None:
        db.session.delete(instance)
        db.session.commit()

    @staticmethod
    def save() -> None:
        db.session.commit()
