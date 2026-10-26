import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.auth import get_firebase_uid
from app.database import get_db
from app.models import SportSpace, Venue
from app.schemas.venue import SportSpaceRead, VenueRead

# The router-level dependency makes every endpoint here require a valid token.
router = APIRouter(
    prefix="/venues",
    tags=["venues"],
    dependencies=[Depends(get_firebase_uid)],
)


@router.get("", response_model=list[VenueRead])
def list_venues(db: Session = Depends(get_db)):
    venues = db.scalars(
        select(Venue).where(Venue.is_active).order_by(Venue.name)
    ).all()
    spaces = db.scalars(select(SportSpace).where(SportSpace.is_active)).all()

    # Group the sports of each venue to build court_count and sports.
    sports_by_venue: dict[uuid.UUID, list[str]] = {}
    for space in spaces:
        sports_by_venue.setdefault(space.venue_id, []).append(space.sport)

    return [
        VenueRead(
            id=venue.id,
            name=venue.name,
            address=venue.address,
            opening_time=venue.opening_time,
            closing_time=venue.closing_time,
            court_count=len(sports_by_venue.get(venue.id, [])),
            sports=sorted(set(sports_by_venue.get(venue.id, []))),
        )
        for venue in venues
    ]


@router.get("/{venue_id}/spaces", response_model=list[SportSpaceRead])
def list_venue_spaces(venue_id: uuid.UUID, db: Session = Depends(get_db)):
    venue = db.get(Venue, venue_id)
    if venue is None or not venue.is_active:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Venue not found",
        )
    return db.scalars(
        select(SportSpace)
        .where(SportSpace.venue_id == venue_id, SportSpace.is_active)
        .order_by(SportSpace.sport, SportSpace.variant, SportSpace.number)
    ).all()