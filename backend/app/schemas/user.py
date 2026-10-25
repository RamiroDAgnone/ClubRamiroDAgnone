import uuid
from datetime import date

from pydantic import BaseModel, ConfigDict, Field, field_validator


class UserCreate(BaseModel):
    """What the app sends when registering. Email comes from the token."""

    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(min_length=1, max_length=100)
    birth_date: date

    @field_validator("first_name", "last_name")
    @classmethod
    def strip_and_check_not_empty(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("must not be empty")
        return value

    @field_validator("birth_date")
    @classmethod
    def birth_date_not_in_future(cls, value: date) -> date:
        if value > date.today():
            raise ValueError("must not be in the future")
        return value


class UserUpdate(UserCreate):
    """What the app sends when editing the profile. Same fields and rules."""


class UserRead(BaseModel):
    """What the API returns. Same keys as lib/models/user.dart expects."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    email: str
    first_name: str
    last_name: str
    birth_date: date
    role: str