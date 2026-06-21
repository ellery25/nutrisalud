import json
import uuid
from datetime import datetime, timezone

from ...extensions import db


class JournalEntry(db.Model):
    __tablename__ = "journal_entries"
    __table_args__ = (db.Index("ix_journal_user_logged", "user_id", "logged_at"),)

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False, index=True
    )
    meal_type = db.Column(db.String(20), nullable=False)  # breakfast|lunch|dinner|snack
    description = db.Column(db.String(500), nullable=False)
    # JSON-encoded list of symptom strings.
    symptoms = db.Column(db.Text, nullable=False, default="[]")
    severity = db.Column(db.Integer, nullable=False, default=0)  # 0..3
    notes = db.Column(db.String(500), nullable=False, default="")
    logged_at = db.Column(db.DateTime, nullable=False, index=True)
    created_at = db.Column(
        db.DateTime, nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "meal_type": self.meal_type,
            "description": self.description,
            "symptoms": json.loads(self.symptoms),
            "severity": self.severity,
            "notes": self.notes,
            "logged_at": self.logged_at.isoformat() if self.logged_at else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
