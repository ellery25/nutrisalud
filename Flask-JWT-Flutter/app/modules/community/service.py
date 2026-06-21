from ...core.errors import ForbiddenError, NotFoundError
from ...core.logging import log_event
from ...core.security import ensure_owner
from ..users.repository import UserRepository
from .models import Comment
from .repository import CommentRepository


class CommentService:
    @staticmethod
    def get_or_404(comment_id: str) -> Comment:
        comment = CommentRepository.by_id(comment_id)
        if comment is None:
            raise NotFoundError("Post", comment_id)
        return comment

    @staticmethod
    def create(author_id: str, content: str, photo: str | None = None) -> Comment:
        if UserRepository.by_id(author_id) is None:
            raise ForbiddenError("Only registered users can post")
        # Timestamp is server-set by the model default; never client-supplied.
        comment = Comment(content=content, photo=photo, user_id=author_id)
        CommentRepository.add(comment)
        log_event("post_created", subject=author_id)
        return comment

    @staticmethod
    def update(comment_id: str, data: dict) -> Comment:
        comment = CommentService.get_or_404(comment_id)
        ensure_owner(comment.user_id)
        comment.content = data["content"]
        CommentRepository.save()
        return comment

    @staticmethod
    def delete(comment_id: str) -> None:
        comment = CommentService.get_or_404(comment_id)
        ensure_owner(comment.user_id)
        CommentRepository.delete(comment)
        log_event("post_deleted", subject=comment.user_id)
