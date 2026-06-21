"""Production entry point: gunicorn 'wsgi:app'."""

import os

from dotenv import load_dotenv

load_dotenv()

from app import create_app  # noqa: E402

app = create_app(os.environ.get("FLASK_ENV"))

if __name__ == "__main__":
    app.run(debug=app.config.get("DEBUG", False), port=5000)
