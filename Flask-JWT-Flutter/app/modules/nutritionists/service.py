from ...core.errors import ApiError, NotFoundError
from ...core.logging import log_event
from ...core.security import ensure_owner, hash_password
from .models import Nutritionist
from .repository import NutritionistRepository

_UPDATABLE_FIELDS = (
    "name",
    "email",
    "description",
    "photo",
    "instagram",
    "website",
    "whatsapp",
    "skill1",
    "skill2",
    "skill3",
)


class NutritionistService:
    @staticmethod
    def get_or_404(nutritionist_id: str) -> Nutritionist:
        nutritionist = NutritionistRepository.by_id(nutritionist_id)
        if nutritionist is None:
            raise NotFoundError("Nutritionist", nutritionist_id)
        return nutritionist

    @staticmethod
    def register(data: dict) -> Nutritionist:
        if NutritionistRepository.by_username(data["username"]):
            raise ApiError("That username is already taken", status=409)
        if NutritionistRepository.by_email(data["email"]):
            raise ApiError("That email is already registered", status=409)
        instagram = data.get("instagram")
        if instagram and NutritionistRepository.by_instagram(instagram):
            raise ApiError("That Instagram handle is already taken", status=409)

        nutritionist = Nutritionist(
            **{k: v for k, v in data.items() if k != "password"},
            password=hash_password(data["password"]),
        )
        NutritionistRepository.add(nutritionist)
        log_event("nutritionist_registered", subject=nutritionist.id)
        return nutritionist

    @staticmethod
    def update(nutritionist_id: str, data: dict) -> Nutritionist:
        nutritionist = NutritionistService.get_or_404(nutritionist_id)
        ensure_owner(nutritionist.id)
        for field in _UPDATABLE_FIELDS:
            if field in data:
                setattr(nutritionist, field, data[field])
        NutritionistRepository.save()
        return nutritionist

    @staticmethod
    def delete(nutritionist_id: str) -> None:
        nutritionist = NutritionistService.get_or_404(nutritionist_id)
        ensure_owner(nutritionist.id)
        NutritionistRepository.delete(nutritionist)
        log_event("nutritionist_deleted", subject=nutritionist_id)
