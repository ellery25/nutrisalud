import uuid
from datetime import datetime, timezone

from ...extensions import db


class ProfessionalTip(db.Model):
    __tablename__ = "professional_tips"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = db.Column(db.String(255), nullable=False)
    content = db.Column(db.Text, nullable=False)
    nutritionist_id = db.Column(
        db.String(36), db.ForeignKey("nutritionists.id"), nullable=False, index=True
    )
    created_at = db.Column(
        db.DateTime, nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    # `nutritionist` backref comes from Nutritionist.professional_tips.

    def to_dict(self) -> dict:
        author = self.nutritionist
        return {
            "id": self.id,
            "title": self.title,
            "content": self.content,
            "nutritionist_id": self.nutritionist_id,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "author": (
                {"id": author.id, "name": author.name, "photo": author.photo}
                if author
                else None
            ),
        }
