from contextlib import asynccontextmanager

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.auth import get_firebase_uid
from app.database import get_db
from app.firebase import init_firebase
from app.reminders import send_upcoming_reminders
from app.routers import bookings, sport_spaces, users, venues
from app.timezone import LOCAL_TZ

init_firebase()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Runs inside the API process: it starts with the server and stops with it.
    scheduler = BackgroundScheduler(timezone=LOCAL_TZ)
    scheduler.add_job(
        send_upcoming_reminders,
        CronTrigger(minute="*/5"),
        id="upcoming_reminders",
        max_instances=1,
        coalesce=True,
        misfire_grace_time=300,
    )
    scheduler.start()
    yield
    scheduler.shutdown()


app = FastAPI(
    title="Club Ramiro D'Agnone API",
    description="REST API for sports spaces management",
    version="0.1.0",
    lifespan=lifespan,
)
app.include_router(users.router)
app.include_router(venues.router)
app.include_router(sport_spaces.router)
app.include_router(bookings.router)

app.add_middleware(
    CORSMiddleware,
    # Any localhost port: Flutter web picks a random one when debugging.
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/auth/check")
def auth_check(firebase_uid: str = Depends(get_firebase_uid)):
    return {"firebase_uid": firebase_uid}


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/health/db")
def health_check_db(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"status": "ok", "database": "connected"}