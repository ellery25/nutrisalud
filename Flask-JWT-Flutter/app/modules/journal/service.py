import json
from collections import Counter
from datetime import date, datetime, time, timedelta, timezone

from ...core.errors import NotFoundError
from ...core.logging import log_event
from ...core.security import ensure_owner
from .models import JournalEntry
from .repository import JournalRepository


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


class JournalService:
    @staticmethod
    def list_entries(
        user_id: str,
        page: int,
        per_page: int,
        date_from: date | None = None,
        date_to: date | None = None,
    ):
        # Calendar dates become inclusive datetime bounds.
        from_dt = datetime.combine(date_from, time.min) if date_from else None
        to_dt = datetime.combine(date_to, time.max) if date_to else None
        return JournalRepository.paginate_for_user(
            user_id, page, per_page, from_dt, to_dt
        )

    @staticmethod
    def create(user_id: str, data: dict) -> JournalEntry:
        logged_at = data["logged_at"]
        if logged_at is None:
            logged_at = _utc_now()
        elif logged_at.tzinfo is None:
            # Naive timestamps are treated as UTC.
            logged_at = logged_at.replace(tzinfo=timezone.utc)
        else:
            logged_at = logged_at.astimezone(timezone.utc)
        entry = JournalEntry(
            user_id=user_id,
            meal_type=data["meal_type"],
            description=data["description"],
            symptoms=json.dumps(data["symptoms"]),
            severity=data["severity"],
            notes=data["notes"],
            logged_at=logged_at,
        )
        JournalRepository.add(entry)
        log_event("journal_entry_created", subject=user_id)
        return entry

    @staticmethod
    def get_or_404(entry_id: str, user_id: str) -> JournalEntry:
        entry = JournalRepository.by_id_for_user(entry_id, user_id)
        if entry is None:
            raise NotFoundError("Journal entry", entry_id)
        return entry

    @staticmethod
    def delete(entry_id: str, user_id: str) -> None:
        entry = JournalService.get_or_404(entry_id, user_id)
        ensure_owner(entry.user_id)
        JournalRepository.delete(entry)
        log_event("journal_entry_deleted", subject=user_id)

    @staticmethod
    def weekly_stats(user_id: str) -> dict:
        """Aggregate the last 7 calendar days (today inclusive) in Python;
        per-user weekly volumes are small."""
        today = _utc_now().date()
        days = [today - timedelta(days=offset) for offset in range(6, -1, -1)]
        since_dt = datetime.combine(days[0], time.min)
        entries = JournalRepository.entries_since(user_id, since_dt)

        meals_per_day = {day: 0 for day in days}
        symptom_days: set[date] = set()
        symptom_counts: Counter[str] = Counter()
        meals_logged = 0
        for entry in entries:
            day = entry.logged_at.date()
            if day not in meals_per_day:
                continue
            meals_logged += 1
            meals_per_day[day] += 1
            symptoms = json.loads(entry.symptoms)
            symptom_counts.update(symptoms)
            if entry.severity > 0 and symptoms:
                symptom_days.add(day)

        return {
            "meals_logged": meals_logged,
            "symptom_days": len(symptom_days),
            "symptom_counts": dict(symptom_counts),
            "meals_per_day": [meals_per_day[day] for day in days],
        }
