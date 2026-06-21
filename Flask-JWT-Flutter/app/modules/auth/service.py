from flask_jwt_extended import create_access_token, create_refresh_token, get_jwt

from ...core.errors import ApiError, UnauthorizedError
from ...core.logging import log_event
from ...core.security import (
    ROLE_NUTRITIONIST,
    ROLE_USER,
    hash_password,
    verify_password,
)
from ...extensions import db
from ..users.models import User
from ..users.repository import UserRepository
from .models import TokenBlocklist


class AuthService:
    @staticmethod
    def _issue_tokens(subject_id: str, role: str) -> dict:
        claims = {"role": role}
        return {
            "access_token": create_access_token(subject_id, additional_claims=claims),
            "refresh_token": create_refresh_token(subject_id, additional_claims=claims),
        }

    @staticmethod
    def login(username: str, password: str) -> dict:
        """Authenticate against users, then the legacy nutritionists table."""
        from ..nutritionists.models import Nutritionist

        account = UserRepository.by_username(username)
        role = account.role if account else ROLE_USER
        if account is None:
            account = db.session.execute(
                db.select(Nutritionist).filter_by(username=username)
            ).scalar_one_or_none()
            role = ROLE_NUTRITIONIST

        if account is None:
            log_event("login_failed", subject=username)
            raise UnauthorizedError()

        matches, needs_rehash = verify_password(account.password, password)
        if not matches:
            log_event("login_failed", subject=account.id)
            raise UnauthorizedError()

        if needs_rehash:  # transparent upgrade of legacy plaintext rows
            account.password = hash_password(password)
            db.session.commit()
            log_event("password_upgraded", subject=account.id)

        log_event("login_success", subject=account.id)
        profile = (
            account.public_dict()
            if isinstance(account, User)
            else {"id": account.id, "name": account.name, "username": account.username}
        )
        return {
            **AuthService._issue_tokens(account.id, role),
            "user": {**profile, "role": role},
        }

    @staticmethod
    def register(name: str, username: str, password: str) -> User:
        if UserRepository.by_username(username):
            raise ApiError("That username is already taken", status=409)
        user = User(name=name, username=username, password=hash_password(password))
        UserRepository.add(user)
        log_event("user_registered", subject=user.id)
        return user

    @staticmethod
    def rotate_refresh_token(subject_id: str) -> dict:
        """Refresh-token rotation: the presented token is revoked,
        a fresh access/refresh pair is issued."""
        AuthService.revoke_current_token()
        role = get_jwt().get("role", ROLE_USER)
        return AuthService._issue_tokens(subject_id, role)

    @staticmethod
    def revoke_current_token() -> None:
        token = get_jwt()
        db.session.add(
            TokenBlocklist(
                jti=token["jti"],
                token_type=token["type"],
                subject=str(token["sub"]),
            )
        )
        db.session.commit()

    @staticmethod
    def is_revoked(jti: str) -> bool:
        return (
            db.session.execute(
                db.select(TokenBlocklist.id).filter_by(jti=jti)
            ).scalar_one_or_none()
            is not None
        )
