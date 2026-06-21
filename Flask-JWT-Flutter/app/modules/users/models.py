import uuid
from datetime import datetime, timezone

from ...extensions import db


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(255), nullable=False)
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    # Column keeps its legacy name but stores a salted hash since 2.0.
    # Pre-2.0 plaintext rows are upgraded transparently on first login.
    password = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), nullable=False, default="user", server_default="user")
    created_at = db.Column(
        db.DateTime, nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    comments = db.relationship("Comment", backref="author", lazy=True)

    def public_dict(self) -> dict:
        """Safe-for-anyone projection. Never expose credentials."""
        return {"id": self.id, "name": self.name, "username": self.username}

    def profile_dict(self) -> dict:
        """Self/admin projection."""
        return {
            "id": self.id,
            "name": self.name,
            "username": self.username,
            "role": self.role,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
