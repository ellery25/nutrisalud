from datetime import datetime, timezone

from ...extensions import db


class DeviceToken(db.Model):
    __tablename__ = "device_tokens"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False, index=True
    )
    token = db.Column(db.String(255), unique=True, nullable=False)
    platform = db.Column(db.String(10), nullable=False, default="android")
    created_at = db.Column(
        db.DateTime, nullable=False, default=lambda: datetime.now(timezone.utc)
    )


class NotificationPreference(db.Model):
    __tablename__ = "notification_preferences"

    user_id = db.Column(db.String(36), db.ForeignKey("users.id"), primary_key=True)
    meal_reminders = db.Column(db.Boolean, nullable=False, default=False)
    hydration_reminders = db.Column(db.Boolean, nullable=False, default=False)
    updated_at = db.Column(
        db.DateTime,
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    def to_dict(self) -> dict:
        return {
            "meal_reminders": self.meal_reminders,
            "hydration_reminders": self.hydration_reminders,
        }
