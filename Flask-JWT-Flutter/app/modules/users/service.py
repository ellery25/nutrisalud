from ...core.errors import NotFoundError, UnauthorizedError
from ...core.logging import log_event
from ...core.security import ensure_owner, hash_password, verify_password
from .models import User
from .repository import UserRepository


class UserService:
    @staticmethod
    def get_or_404(user_id: str) -> User:
        user = UserRepository.by_id(user_id)
        if user is None:
            raise NotFoundError("User", user_id)
        return user

    @staticmethod
    def update(user_id: str, data: dict) -> User:
        user = UserService.get_or_404(user_id)
        ensure_owner(user.id)
        if "name" in data:
            user.name = data["name"]
        UserRepository.save()
        return user

    @staticmethod
    def change_password(user_id: str, current: str, new: str) -> None:
        user = UserService.get_or_404(user_id)
        ensure_owner(user.id)
        matches, _ = verify_password(user.password, current)
        if not matches:
            raise UnauthorizedError("Current password is incorrect")
        user.password = hash_password(new)
        UserRepository.save()
        log_event("password_changed", subject=user.id)

    @staticmethod
    def delete(user_id: str) -> None:
        user = UserService.get_or_404(user_id)
        ensure_owner(user.id)
        UserRepository.delete(user)
        log_event("user_deleted", subject=user_id)
