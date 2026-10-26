"""add bookings no overlap constraint

Revision ID: 483a78b6f617
Revises: 9077cdc9b650
Create Date: 2026-10-25 20:09:34.998253

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '483a78b6f617'
down_revision: Union[str, Sequence[str], None] = '9077cdc9b650'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Needed to mix "=" on a uuid with "&&" on a range in the same constraint.
    op.execute("CREATE EXTENSION IF NOT EXISTS btree_gist")
    # Same space + overlapping time range = rejected. Cancelled bookings
    # are ignored. tstzrange is [start, end), so 18-19 and 19-20 are fine.
    op.execute(
        """
        ALTER TABLE bookings ADD CONSTRAINT ex_bookings_no_overlap
        EXCLUDE USING gist (
            sport_space_id WITH =,
            tstzrange(start_at, end_at) WITH &&
        ) WHERE (status = 'active')
        """
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.execute("ALTER TABLE bookings DROP CONSTRAINT ex_bookings_no_overlap")
