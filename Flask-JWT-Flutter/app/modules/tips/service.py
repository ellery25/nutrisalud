from ...core.errors import NotFoundError
from ...core.logging import log_event
from ...core.security import ensure_owner
from .models import ProfessionalTip
from .repository import TipRepository


class TipService:
    @staticmethod
    def get_or_404(tip_id: str) -> ProfessionalTip:
        tip = TipRepository.by_id(tip_id)
        if tip is None:
            raise NotFoundError("Tip", tip_id)
        return tip

    @staticmethod
    def create(nutritionist_id: str, title: str, content: str) -> ProfessionalTip:
        tip = ProfessionalTip(
            title=title, content=content, nutritionist_id=nutritionist_id
        )
        TipRepository.add(tip)
        log_event("tip_created", subject=nutritionist_id)
        return tip

    @staticmethod
    def update(tip_id: str, data: dict) -> ProfessionalTip:
        tip = TipService.get_or_404(tip_id)
        ensure_owner(tip.nutritionist_id)
        if "title" in data:
            tip.title = data["title"]
        if "content" in data:
            tip.content = data["content"]
        TipRepository.save()
        return tip

    @staticmethod
    def delete(tip_id: str) -> None:
        tip = TipService.get_or_404(tip_id)
        ensure_owner(tip.nutritionist_id)
        TipRepository.delete(tip)
        log_event("tip_deleted", subject=tip.nutritionist_id)
