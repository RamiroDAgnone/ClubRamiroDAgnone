import datetime as dt

from sqlalchemy import select

from app.database import SessionLocal
from app.models import Booking, SportSpace, Venue
from app.notifications import send_to_user
from app.timezone import LOCAL_TZ


def send_upcoming_reminders() -> int:
    """Warns about the active bookings that start within the next hour.

    Example: a booking for 14:00 is warned at the first run after 13:00,
    even if it was created at 13:13. reminder_sent_at avoids duplicates.
    Returns how many bookings were processed.
    """
    now = dt.datetime.now(LOCAL_TZ)
    window_end = now + dt.timedelta(hours=1)

    with SessionLocal() as db:
        rows = db.execute(
            select(Booking, SportSpace, Venue)
            .join(SportSpace, Booking.sport_space_id == SportSpace.id)
            .join(Venue, SportSpace.venue_id == Venue.id)
            .where(
                Booking.status == "active",
                Booking.reminder_sent_at.is_(None),
                Booking.start_at > now,
                Booking.start_at <= window_end,
            )
        ).all()

        for booking, space, venue in rows:
            start_local = booking.start_at.astimezone(LOCAL_TZ)
            send_to_user(
                db,
                booking.user_id,
                "¡Tu reserva empieza pronto!",
                f"{venue.name} · {space.sport} cancha {space.number} a las {start_local:%H:%M}",
            )
            # Marked even if the user has no device: do not retry forever.
            booking.reminder_sent_at = now
            db.commit()

    return len(rows)