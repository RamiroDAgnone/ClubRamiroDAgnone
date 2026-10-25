import firebase_admin
from firebase_admin import credentials

from app.config import settings


def init_firebase() -> None:
    """Starts the Firebase Admin SDK once."""
    if not firebase_admin._apps:
        cred = credentials.Certificate(settings.firebase_credentials_path)
        firebase_admin.initialize_app(cred)