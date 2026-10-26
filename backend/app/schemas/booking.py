import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, field_validator


class BookingCreate(BaseModel):
    """What the app sends. The user comes from the token, the price is calculated."""

    sport_space_id: uuid.UUID
    start_at: datetime
    end_at: datetime

    @field_validator("start_at", "end_at")
    @classmethod
    def must_have_timezone(cls, value: datetime) -> datetime:
        if value.tzinfo is None:
            raise ValueError("must include a timezone offset")
        return value


class BookingRead(BaseModel):
    id: uuid.UUID
    sport_space_id: uuid.UUID
    venue_name: str
    sport: str
    variant: str | None
    space_number: int
    space_name: str
    start_at: datetime
    end_at: datetime
    price: float
    # "completed" is not stored: it is an active booking whose end already passed.
    status: Literal["active", "completed", "cancelled"]