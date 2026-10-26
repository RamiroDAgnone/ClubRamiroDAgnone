from firebase_admin import messaging
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import DeviceToken


def send_to_user(db: Session, user_id, title: str, body: str) -> int:
    """Sends a push to every device of the user. Returns how many were delivered."""
    tokens = db.scalars(
        select(DeviceToken).where(DeviceToken.user_id == user_id)
    ).all()

    delivered = 0
    for device in tokens:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            token=device.token,
        )
        try:
            messaging.send(message)
            delivered += 1
        except messaging.UnregisteredError:
            # The app was uninstalled or the token expired: forget it.
            db.delete(device)
    db.commit()
    return delivered