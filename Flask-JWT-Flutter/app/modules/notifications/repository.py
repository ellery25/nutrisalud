"""Data access for device tokens and notification preferences."""

from ...extensions import db
from .models import DeviceToken, NotificationPreference


class NotificationRepository:
    @staticmethod
    def device_by_token(token: str) -> DeviceToken | None:
        return db.session.execute(
            db.select(DeviceToken).filter_by(token=token)
        ).scalar_one_or_none()

    @staticmethod
    def preferences_by_user(user_id: str) -> NotificationPreference | None:
        return db.session.get(NotificationPreference, user_id)

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

    @staticmethod
    def all_preferences() -> list[NotificationPreference]:
        return (
            db.session.execute(db.select(NotificationPreference)).scalars().all()
        )

    @staticmethod
    def devices_by_user(user_id: str) -> list[DeviceToken]:
        return (
            db.session.execute(
                db.select(DeviceToken).filter_by(user_id=user_id)
            )
            .scalars()
            .all()
        )
