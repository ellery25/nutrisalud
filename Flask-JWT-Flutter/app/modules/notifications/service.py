from ...core.errors import ApiError
from ...core.logging import log_event
from .models import DeviceToken, NotificationPreference
from .repository import NotificationRepository


class NotificationService:
    @staticmethod
    def register_device(user_id: str, token: str, platform: str) -> DeviceToken:
        device = NotificationRepository.device_by_token(token)
        if device is None:
            device = DeviceToken(user_id=user_id, token=token, platform=platform)
            NotificationRepository.add(device)
        else:
            # Token already known: the device changed owner or platform.
            device.user_id = user_id
            device.platform = platform
            NotificationRepository.save()
        log_event("device_registered", subject=user_id)
        return device

    @staticmethod
    def unregister_device(user_id: str, token: str) -> None:
        device = NotificationRepository.device_by_token(token)
        # Silently ok if absent; never delete another user's registration.
        if device is not None and device.user_id == user_id:
            NotificationRepository.delete(device)
            log_event("device_unregistered", subject=user_id)

    @staticmethod
    def get_or_create_preferences(user_id: str) -> NotificationPreference:
        prefs = NotificationRepository.preferences_by_user(user_id)
        if prefs is None:
            prefs = NotificationPreference(user_id=user_id)
            NotificationRepository.add(prefs)
        return prefs

    @staticmethod
    def update_preferences(user_id: str, data: dict) -> NotificationPreference:
        if not data:
            raise ApiError("No preferences provided")
        prefs = NotificationService.get_or_create_preferences(user_id)
        if "meal_reminders" in data:
            prefs.meal_reminders = data["meal_reminders"]
        if "hydration_reminders" in data:
            prefs.hydration_reminders = data["hydration_reminders"]
        NotificationRepository.save()
        return prefs
