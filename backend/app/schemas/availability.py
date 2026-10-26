from datetime import datetime

from pydantic import BaseModel


class TimeSlotRead(BaseModel):
    start_at: datetime
    end_at: datetime
    is_available: bool