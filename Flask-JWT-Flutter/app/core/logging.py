"""Structured logging (Phase 5 — observability).

JSON logs in production (one object per line, machine-parsable);
human-readable logs in development. A request middleware records
method, path, status, latency and the authenticated subject.
"""

import json
import logging
import sys
import time
import uuid

from flask import g, request


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        entry = {
            "ts": self.formatTime(record, "%Y-%m-%dT%H:%M:%S%z"),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        for attr in ("request_id", "method", "path", "status", "duration_ms", "subject", "event"):
            value = getattr(record, attr, None)
            if value is not None:
                entry[attr] = value
        if record.exc_info:
            entry["exception"] = self.formatException(record.exc_info)
        return json.dumps(entry)


def configure_logging(app) -> None:
    handler = logging.StreamHandler(sys.stdout)
    if app.config.get("JSON_LOGS", True):
        handler.setFormatter(JsonFormatter())
    else:
        handler.setFormatter(
            logging.Formatter("%(asctime)s %(levelname)s %(name)s: %(message)s")
        )

    root = logging.getLogger()
    root.handlers = [handler]
    root.setLevel(app.config.get("LOG_LEVEL", "INFO"))

    access_logger = logging.getLogger("nutrisalud.access")

    @app.before_request
    def _start_timer():
        g.request_start = time.perf_counter()
        g.request_id = request.headers.get("X-Request-Id", uuid.uuid4().hex[:12])

    @app.after_request
    def _log_request(response):
        duration_ms = round(
            (time.perf_counter() - getattr(g, "request_start", time.perf_counter()))
            * 1000,
            1,
        )
        access_logger.info(
            "request",
            extra={
                "request_id": getattr(g, "request_id", None),
                "method": request.method,
                "path": request.path,
                "status": response.status_code,
                "duration_ms": duration_ms,
            },
        )
        response.headers["X-Request-Id"] = getattr(g, "request_id", "")
        return response


def log_event(event: str, **fields) -> None:
    """Business/auth event logging (e.g. login_success, post_created)."""
    logging.getLogger("nutrisalud.events").info(
        event, extra={"event": event, **fields}
    )
