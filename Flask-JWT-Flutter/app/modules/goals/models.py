import uuid
from datetime import datetime, timezone

from ...extensions import db


class Goal(db.Model):
    __tablename__ = "nutrition_goals"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False, index=True
    )
    # water|fruit_veg|home_cooked|mindful_eating|custom
    goal_type = db.Column(db.String(20), nullable=False)
    title = db.Column(db.String(100), nullable=False)
    daily_target = db.Column(db.Integer, nullable=False)
    created_at = db.Column(
        db.DateTime, nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    check_ins = db.relationship(
        "GoalCheckIn", backref="goal", lazy=True, cascade="all, delete-orphan"
    )

    def to_dict(self, today_count: int, last7: list[int]) -> dict:
        return {
            "id": self.id,
            "goal_type": self.goal_type,
            "title": self.title,
            "daily_target": self.daily_target,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "today_count": today_count,
            "last_7_days": last7,  # oldest → today
        }


class GoalCheckIn(db.Model):
    __tablename__ = "goal_check_ins"
    __table_args__ = (
        db.UniqueConstraint("goal_id", "day", name="uq_checkin_goal_day"),
    )

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    goal_id = db.Column(
        db.String(36), db.ForeignKey("nutrition_goals.id"), nullable=False
    )
    day = db.Column(db.Date, nullable=False)
    count = db.Column(db.Integer, nullable=False, default=0)
