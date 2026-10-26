import datetime as dt
import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.auth import get_firebase_uid
from app.database import get_db
from app.models import Booking, SportSpace, Venue
from app.schemas.availability import TimeSlotRead
from app.timezone import LOCAL_TZ

router = APIRouter(
    prefix="/sport-spaces",
    tags=["sport-spaces"],
    dependencies=[Depends(get_firebase_uid)],
)


@router.get("/{space_id}/availability", response_model=list[TimeSlotRead])
def get_availability(
    space_id: uuid.UUID,
    date: dt.date,
    duration: int = Query(1, ge=1, le=4, description="Duration in whole hours"),
    db: Session = Depends(get_db),
):
    space = db.get(SportSpace, space_id)
    venue = db.get(Venue, space.venue_id) if space is not None else None
    if space is None or not space.is_active or not venue.is_active:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sport space not found",
        )

    opening = dt.datetime.combine(date, venue.opening_time, tzinfo=LOCAL_TZ)
    closing = dt.datetime.combine(date, venue.closing_time, tzinfo=LOCAL_TZ)

    # Active bookings of this space that touch the opening-closing window.
    taken = db.scalars(
        select(Booking).where(
            Booking.sport_space_id == space_id,
            Booking.status == "active",
            Booking.start_at < closing,
            Booking.end_at > opening,
        )
    ).all()

    now = dt.datetime.now(LOCAL_TZ)
    slots: list[TimeSlotRead] = []
    start = opening
    # The end can never go past the closing time.
    while start + dt.timedelta(hours=duration) <= closing:
        end = start + dt.timedelta(hours=duration)
        # Two ranges overlap when each one starts before the other ends.
        overlaps = any(b.start_at < end and b.end_at > start for b in taken)
        slots.append(
            TimeSlotRead(
                start_at=start,
                end_at=end,
                is_available=start > now and not overlaps,
            )
        )
        start += dt.timedelta(hours=1)
    return slots