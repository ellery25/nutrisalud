from datetime import date, timedelta

from ...core.errors import NotFoundError
from ...core.logging import log_event
from ...core.security import ensure_owner
from .models import Goal, GoalCheckIn
from .repository import GoalRepository


class GoalService:
    @staticmethod
    def list_goals(user_id: str) -> list[dict]:
        goals = GoalRepository.goals_for_user(user_id)
        today = date.today()
        days = [today - timedelta(days=offset) for offset in range(6, -1, -1)]
        # One query for every goal's check-ins over the window.
        check_ins = GoalRepository.check_ins_between(
            [g.id for g in goals], days[0], today
        )
        counts = {(c.goal_id, c.day): c.count for c in check_ins}
        return [
            g.to_dict(
                today_count=counts.get((g.id, today), 0),
                last7=[counts.get((g.id, day), 0) for day in days],
            )
            for g in goals
        ]

    @staticmethod
    def create(user_id: str, data: dict) -> Goal:
        goal = Goal(
            user_id=user_id,
            goal_type=data["goal_type"],
            title=data["title"],
            daily_target=data["daily_target"],
        )
        GoalRepository.add(goal)
        log_event("goal_created", subject=user_id)
        return goal

    @staticmethod
    def get_or_404(goal_id: str, user_id: str) -> Goal:
        goal = GoalRepository.by_id_for_user(goal_id, user_id)
        if goal is None:
            raise NotFoundError("Goal", goal_id)
        return goal

    @staticmethod
    def delete(goal_id: str, user_id: str) -> None:
        goal = GoalService.get_or_404(goal_id, user_id)
        ensure_owner(goal.user_id)
        GoalRepository.delete(goal)
        log_event("goal_deleted", subject=user_id)

    @staticmethod
    def check_in(user_id: str, goal_id: str, delta: int) -> dict:
        goal = GoalService.get_or_404(goal_id, user_id)
        ensure_owner(goal.user_id)
        today = date.today()
        row = GoalRepository.get_check_in(goal.id, today)
        if row is None:
            row = GoalCheckIn(goal_id=goal.id, day=today, count=0)
            GoalRepository.add(row)
        row.count = max(0, row.count + delta)
        GoalRepository.save()
        log_event("goal_checked_in", subject=user_id)
        return {"goal_id": goal.id, "day": today.isoformat(), "count": row.count}
