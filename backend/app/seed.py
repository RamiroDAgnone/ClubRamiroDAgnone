from datetime import time
from decimal import Decimal

from sqlalchemy import select

from app.database import SessionLocal
from app.models import SportSpace, Venue
from app.naming import build_space_name

VENUES = [
    {"name": "Morón", "address": "Rivadavia 19850"},
    {"name": "Ramos Mejía", "address": "Av. de Mayo 450"},
    {"name": "San Justo", "address": "Av. Illia 3300"},
    {"name": "Castelar", "address": "San Martín 120"},
]

# Venue name -> list of (sport, variant, quantity, price per hour).
# All the addresses and prices are sample data.
SPACES = {
    "Morón": [("Fútbol", "F5", 2, "7600"), ("Paddle", None, 2, "6200")],
    "Ramos Mejía": [("Básquet", None, 1, "5800"), ("Vóley", None, 2, "5200")],
    "San Justo": [("Paddle", None, 2, "6200"), ("Hockey", None, 1, "9000")],
    "Castelar": [
        ("Fútbol", "F5", 1, "7600"),
        ("Fútbol", "F11", 1, "15000"),
        ("Tenis", None, 2, "5500"),
    ],
}


def seed() -> None:
    with SessionLocal() as db:
        for venue_data in VENUES:
            venue = db.scalar(select(Venue).where(Venue.name == venue_data["name"]))
            if venue is None:
                venue = Venue(
                    name=venue_data["name"],
                    address=venue_data["address"],
                    opening_time=time(8, 0),
                    closing_time=time(23, 0),
                )
                db.add(venue)
                db.flush()  # assigns the id without finishing the transaction

            for sport, variant, quantity, price in SPACES[venue.name]:
                for number in range(1, quantity + 1):
                    name = build_space_name(
                        venue.name, venue.address, sport, variant, number
                    )
                    exists = db.scalar(select(SportSpace).where(SportSpace.name == name))
                    if exists is None:
                        db.add(
                            SportSpace(
                                venue_id=venue.id,
                                sport=sport,
                                variant=variant,
                                number=number,
                                name=name,
                                price_per_hour=Decimal(price),
                            )
                        )
        db.commit()
    print("Seed completed")


if __name__ == "__main__":
    seed()