import os

from flask import Blueprint, request

from ...core.responses import created, ok
from ...core.security import ROLE_USER, current_identity, require_roles
from ...core.validation import validate_body
from .push import send_hydration_reminder, send_meal_reminder
from .repository import NotificationRepository
from .schemas import (
    RegisterDeviceSchema,
    UnregisterDeviceSchema,
    UpdatePreferencesSchema,
)
from .service import NotificationService

notifications_bp = Blueprint("notifications", __name__)


@notifications_bp.post("/devices")
@require_roles(ROLE_USER)
@validate_body(RegisterDeviceSchema())
def register_device(body: dict):
    device = NotificationService.register_device(
        current_identity(), body["token"], body["platform"]
    )
    return created(
        {"token": device.token, "platform": device.platform}, "Device registered"
    )


@notifications_bp.delete("/devices")
@require_roles(ROLE_USER)
@validate_body(UnregisterDeviceSchema())
def unregister_device(body: dict):
    NotificationService.unregister_device(current_identity(), body["token"])
    return ok(message="Device unregistered")


@notifications_bp.get("/preferences")
@require_roles(ROLE_USER)
def get_preferences():
    prefs = NotificationService.get_or_create_preferences(current_identity())
    return ok(prefs.to_dict())


@notifications_bp.put("/preferences")
@require_roles(ROLE_USER)
@validate_body(UpdatePreferencesSchema())
def update_preferences(body: dict):
    prefs = NotificationService.update_preferences(current_identity(), body)
    return ok(prefs.to_dict(), "Preferences updated")


@notifications_bp.post("/send-reminders")
def send_scheduled_reminders():
    """Cron endpoint — protected by X-Cron-Secret header.

    Triggered by an external scheduler (Render cron job, GitHub Actions, etc.).
    Set CRON_SECRET env var to a random string and pass it as the header value.
    """
    cron_secret = os.environ.get("CRON_SECRET")
    if not cron_secret or request.headers.get("X-Cron-Secret") != cron_secret:
        return {"success": False, "message": "Unauthorized"}, 401

    sent = 0
    for pref in NotificationRepository.all_preferences():
        if not pref.meal_reminders and not pref.hydration_reminders:
            continue
        for device in NotificationRepository.devices_by_user(pref.user_id):
            if pref.meal_reminders and send_meal_reminder(device.token):
                sent += 1
            if pref.hydration_reminders and send_hydration_reminder(device.token):
                sent += 1

    return ok({"notifications_sent": sent}, "Reminders dispatched")
