import uuid

from ...extensions import db


class Nutritionist(db.Model):
    __tablename__ = "nutritionists"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(255), nullable=False)
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    email = db.Column(db.String(255), unique=True, nullable=False)
    # Column keeps its legacy name but stores a salted hash since 2.0.
    # Pre-2.0 plaintext rows are upgraded transparently on first login.
    password = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    rating = db.Column(db.Numeric(2, 1), nullable=False, server_default="1.0")
    photo = db.Column(db.Text)
    instagram = db.Column(db.String(20), unique=True, nullable=True)
    website = db.Column(db.String(100))
    whatsapp = db.Column(db.String(15))
    skill1 = db.Column(db.String(50), nullable=False)
    skill2 = db.Column(db.String(50))
    skill3 = db.Column(db.String(50))

    professional_tips = db.relationship(
        "ProfessionalTip", backref="nutritionist", lazy=True
    )

    def public_dict(self) -> dict:
        """Safe-for-anyone projection. Never expose credentials."""
        return {
            "id": self.id,
            "name": self.name,
            "username": self.username,
            "email": self.email,
            "description": self.description,
            "rating": float(self.rating) if self.rating is not None else None,
            "photo": self.photo,
            "instagram": self.instagram,
            "website": self.website,
            "whatsapp": self.whatsapp,
            "skills": [
                s for s in (self.skill1, self.skill2, self.skill3) if s is not None
            ],
            "skill1": self.skill1,
            "skill2": self.skill2,
            "skill3": self.skill3,
            "type": "nutritionist",
        }
