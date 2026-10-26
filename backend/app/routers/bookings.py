import datetime as dt
import uuid
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.auth import get_firebase_uid
from app.database import get_db
from app.models import Booking, SportSpace, Venue
from app.routers.users import get_current_user
from app.schemas.booking import BookingCreate, BookingRead
from app.timezone import LOCAL_TZ

router = APIRouter(prefix="/bookings", tags=["bookings"])


def _bad_request(detail: str) -> HTTPException:
    return HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=detail)


def _status_of(booking: Booking, now: dt.datetime) -> str:
    if booking.status == "cancelled":
        return "cancelled"
    if booking.end_at <= now:
        return "completed"
    return "active"


def _to_read(
    booking: Booking, space: SportSpace, venue: Venue, now: dt.datetime
) -> BookingRead:
    return BookingRead(
        id=booking.id,
        sport_space_id=space.id,
        venue_name=venue.name,
        sport=space.sport,
        variant=space.variant,
        space_number=space.number,
        space_name=space.name,
        start_at=booking.start_at,
        end_at=booking.end_at,
        price=float(booking.price),
        status=_status_of(booking, now),
    )


def _bookings_query():
    """Bookings with their space and venue, ready to be filtered."""
    return (
        select(Booking, SportSpace, Venue)
        .join(SportSpace, Booking.sport_space_id == SportSpace.id)
        .join(Venue, SportSpace.venue_id == Venue.id)
    )


def _validate_rules(start: dt.datetime, end: dt.datetime, venue: Venue) -> None:
    """Business rules of the assignment. start and end are in local time."""
    for moment in (start, end):
        if moment.minute != 0 or moment.second != 0 or moment.microsecond != 0:
            raise _bad_request("Start and end times must be whole hours")
    if end - start < dt.timedelta(hours=1):
        raise _bad_request("The minimum duration is one hour")
    if start <= dt.datetime.now(LOCAL_TZ):
        raise _bad_request("Bookings must be for a future time")

    opening = dt.datetime.combine(start.date(), venue.opening_time, tzinfo=LOCAL_TZ)
    closing = dt.datetime.combine(start.date(), venue.closing_time, tzinfo=LOCAL_TZ)
    if start < opening or end > closing:
        raise _bad_request("The booking must be within the venue opening hours")


@router.post("", response_model=BookingRead, status_code=status.HTTP_201_CREATED)
def create_booking(
    data: BookingCreate,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    user = get_current_user(firebase_uid, db)

    space = db.get(SportSpace, data.sport_space_id)
    venue = db.get(Venue, space.venue_id) if space is not None else None
    if space is None or not space.is_active or not venue.is_active:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sport space not found",
        )

    start = data.start_at.astimezone(LOCAL_TZ)
    end = data.end_at.astimezone(LOCAL_TZ)
    _validate_rules(start, end, venue)

    # The backend checks the availability before saving, as the assignment asks.
    overlapping = db.scalar(
        select(Booking.id)
        .where(
            Booking.sport_space_id == space.id,
            Booking.status == "active",
            Booking.start_at < data.end_at,
            Booking.end_at > data.start_at,
        )
        .limit(1)
    )
    if overlapping is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="The time slot is not available",
        )

    hours = int((end - start).total_seconds() // 3600)
    booking = Booking(
        user_id=user.id,
        sport_space_id=space.id,
        start_at=data.start_at,
        end_at=data.end_at,
        price=space.price_per_hour * hours,
    )
    db.add(booking)
    try:
        db.commit()
    except IntegrityError:
        # Two requests at the same time: the exclusion constraint caught it.
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="The time slot is not available",
        )
    db.refresh(booking)
    return _to_read(booking, space, venue, dt.datetime.now(dt.timezone.utc))


@router.get("/me", response_model=list[BookingRead])
def list_my_bookings(
    scope: Literal["upcoming", "history"],
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    user = get_current_user(firebase_uid, db)
    now = dt.datetime.now(dt.timezone.utc)

    query = _bookings_query().where(Booking.user_id == user.id)
    if scope == "upcoming":
        query = query.where(Booking.status == "active", Booking.end_at > now)
        query = query.order_by(Booking.start_at)
    else:
        # History: cancelled ones and the ones whose time already finished.
        query = query.where(
            or_(Booking.status == "cancelled", Booking.end_at <= now)
        )
        query = query.order_by(Booking.start_at.desc())

    rows = db.execute(query).all()
    return [_to_read(b, s, v, now) for b, s, v in rows]


@router.patch("/{booking_id}/cancel", response_model=BookingRead)
def cancel_booking(
    booking_id: uuid.UUID,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    user = get_current_user(firebase_uid, db)
    now = dt.datetime.now(dt.timezone.utc)

    # Filtering by user_id too: nobody can cancel (or even see) other's bookings.
    row = db.execute(
        _bookings_query().where(
            Booking.id == booking_id, Booking.user_id == user.id
        )
    ).first()
    if row is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found",
        )
    booking, space, venue = row

    if booking.status != "active":
        raise _bad_request("The booking is already cancelled")
    if booking.start_at <= now:
        raise _bad_request("Past or in-progress bookings cannot be cancelled")

    booking.status = "cancelled"
    booking.cancelled_by = "user"
    booking.cancelled_at = now
    db.commit()
    db.refresh(booking)
    return _to_read(booking, space, venue, now)