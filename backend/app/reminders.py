import datetime as dt

from sqlalchemy import select

from app.database import SessionLocal
from app.models import Booking, SportSpace, Venue
from app.notifications import send_to_user
from app.timezone import LOCAL_TZ


def send_hourly_reminders() -> int:
    """At the top of an hour, warns about the bookings starting in the next hour.

    Example: at 7:00 it handles the bookings that start at 8:00.
    Returns how many bookings were processed.
    """
    now = dt.datetime.now(LOCAL_TZ)
    window_start = now.replace(minute=0, second=0, microsecond=0) + dt.timedelta(hours=1)
    window_end = window_start + dt.timedelta(hours=1)

    with SessionLocal() as db:
        rows = db.execute(
            select(Booking, SportSpace, Venue)
            .join(SportSpace, Booking.sport_space_id == SportSpace.id)
            .join(Venue, SportSpace.venue_id == Venue.id)
            .where(
                Booking.status == "active",
                Booking.reminder_sent_at.is_(None),
                Booking.start_at >= window_start,
                Booking.start_at < window_end,
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
            # Marked even if the user has no device: the window passes anyway.
            booking.reminder_sent_at = now
            db.commit()

    return len(rows)