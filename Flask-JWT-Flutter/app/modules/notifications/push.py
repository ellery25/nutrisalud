"""Firebase Cloud Messaging push helpers.

Set up:
  1. Firebase Console → Project Settings → Service Accounts → Generate new private key
  2. Set FIREBASE_SERVICE_ACCOUNT env var to the full JSON content of that key file.

Without FIREBASE_SERVICE_ACCOUNT, all send_* calls return False silently.
"""

from __future__ import annotations

import json
import logging
import os
from functools import lru_cache

logger = logging.getLogger(__name__)

try:
    import firebase_admin
    from firebase_admin import credentials, messaging

    _FCM_AVAILABLE = True
except ImportError:
    _FCM_AVAILABLE = False
    logger.warning("firebase-admin not installed — push notifications disabled.")


@lru_cache(maxsize=1)
def _app():
    """Initialise Firebase Admin SDK once per process."""
    sa_json = os.environ.get("FIREBASE_SERVICE_ACCOUNT")
    if not sa_json:
        raise RuntimeError("FIREBASE_SERVICE_ACCOUNT env var is not set.")
    cred = credentials.Certificate(json.loads(sa_json))
    return firebase_admin.initialize_app(cred)


def _send(fcm_token: str, title: str, body: str, data: dict | None = None) -> bool:
    if not _FCM_AVAILABLE:
        return False
    try:
        _app()
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            token=fcm_token,
        )
        messaging.send(message)
        return True
    except Exception as exc:
        logger.warning("FCM send failed (token ...%s): %s", fcm_token[-6:], exc)
        return False


def send_meal_reminder(fcm_token: str) -> bool:
    return _send(
        fcm_token,
        title="Time to log your meal",
        body="Tap to record what you've eaten and how you feel.",
        data={"action": "open_journal"},
    )


def send_hydration_reminder(fcm_token: str) -> bool:
    return _send(
        fcm_token,
        title="Hydration check",
        body="Have you had enough water today?",
        data={"action": "open_goals"},
    )
