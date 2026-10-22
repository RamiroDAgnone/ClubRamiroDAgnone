import uuid
from decimal import Decimal

from sqlalchemy import ForeignKey, Numeric, String, text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class SportSpace(Base):
    __tablename__ = "sport_spaces"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    venue_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("venues.id"))
    sport: Mapped[str] = mapped_column(String(50))  # e.g. "Fútbol", "Paddle"
    variant: Mapped[str | None] = mapped_column(String(50))  # e.g. "F5", "F11"
    number: Mapped[int]
    name: Mapped[str] = mapped_column(String(255), unique=True)
    price_per_hour: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    is_active: Mapped[bool] = mapped_column(default=True, server_default=text("true"))