import uuid
from datetime import datetime, timezone

from ...extensions import db


class Comment(db.Model):
    __tablename__ = "comments"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    content = db.Column(db.Text, nullable=False)
    photo = db.Column(db.Text)  # base64-encoded, optional
    timestamp = db.Column(
        db.DateTime,
        nullable=False,
        index=True,
        default=lambda: datetime.now(timezone.utc),
    )
    user_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False, index=True
    )

    # `author` backref comes from User.comments (users module).

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "content": self.content,
            "photo": self.photo,
            "timestamp": self.timestamp.isoformat() if self.timestamp else None,
            "author": self.author.public_dict() if self.author else None,
            "user_id": self.user_id,  # kept for backward compat
        }
