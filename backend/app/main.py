from fastapi import Depends, FastAPI
from sqlalchemy import text
from sqlalchemy.orm import Session
from app.routers import users

from app.database import get_db

from app.auth import get_firebase_uid

app = FastAPI(
    title="Club Ramiro D'Agnone API",
    description="REST API for sports spaces management",
    version="0.1.0",
)
app.include_router(users.router)

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    # Any localhost port: Flutter web picks a random one when debugging.
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["*"],
    allow_headers=["*"],
)

from app.firebase import init_firebase

init_firebase()

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