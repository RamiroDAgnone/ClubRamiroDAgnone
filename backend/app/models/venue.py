import uuid
from datetime import time

from sqlalchemy import String, Time, text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Venue(Base):
    __tablename__ = "venues"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100), unique=True)
    address: Mapped[str] = mapped_column(String(255))
    opening_time: Mapped[time] = mapped_column(Time)
    closing_time: Mapped[time] = mapped_column(Time)
    is_active: Mapped[bool] = mapped_column(default=True, server_default=text("true"))