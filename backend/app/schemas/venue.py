import datetime
import uuid

from pydantic import BaseModel, ConfigDict


class VenueRead(BaseModel):
    """What the API returns for a venue. court_count and sports are calculated."""

    id: uuid.UUID
    name: str
    address: str
    opening_time: datetime.time
    closing_time: datetime.time
    court_count: int
    sports: list[str]


class SportSpaceRead(BaseModel):
    """What the API returns for a sport space (court)."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    venue_id: uuid.UUID
    sport: str
    variant: str | None
    number: int
    name: str
    price_per_hour: float