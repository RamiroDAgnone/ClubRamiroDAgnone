from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.auth import get_decoded_token, get_firebase_uid
from app.database import get_db
from app.models import User, DeviceToken
from app.schemas.user import UserCreate, UserRead, UserUpdate
from app.schemas.device_token import DeviceTokenCreate
from app.notifications import send_to_user

router = APIRouter(prefix="/users", tags=["users"])


@router.post("", response_model=UserRead, status_code=status.HTTP_201_CREATED)
def create_user(
    data: UserCreate,
    token: dict = Depends(get_decoded_token),
    db: Session = Depends(get_db),
):
    firebase_uid = token["uid"]
    email = token.get("email")
    if email is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The token has no email",
        )

    already_exists = db.scalar(
        select(User).where((User.firebase_uid == firebase_uid) | (User.email == email))
    )
    if already_exists is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User already registered",
        )

    user = User(
        firebase_uid=firebase_uid,
        email=email,
        first_name=data.first_name,
        last_name=data.last_name,
        birth_date=data.birth_date,
    )
    db.add(user)
    try:
        db.commit()
    except IntegrityError:
        # Two requests at the same time: the unique constraints caught it.
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User already registered",
        )
    db.refresh(user)
    return user

def get_current_user(firebase_uid: str, db: Session) -> User:
    user = db.scalar(select(User).where(User.firebase_uid == firebase_uid))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found",
        )
    return user


@router.get("/me", response_model=UserRead)
def read_me(
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    return get_current_user(firebase_uid, db)


@router.put("/me", response_model=UserRead)
def update_me(
    data: UserUpdate,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    user = get_current_user(firebase_uid, db)
    user.first_name = data.first_name
    user.last_name = data.last_name
    user.birth_date = data.birth_date
    db.commit()
    db.refresh(user)
    return user

@router.post("/me/device-token")
def register_device_token(
    data: DeviceTokenCreate,
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    user = get_current_user(firebase_uid, db)

    existing = db.scalar(select(DeviceToken).where(DeviceToken.token == data.token))
    if existing is not None:
        # Same device, maybe another account logged in: it now belongs to this user.
        existing.user_id = user.id
        existing.platform = data.platform
    else:
        db.add(DeviceToken(user_id=user.id, token=data.token, platform=data.platform))
    db.commit()
    # Not a 204: ApiClient always tries to decode a JSON body.
    return {"status": "ok"}

@router.post("/me/test-notification")
def test_notification(
    firebase_uid: str = Depends(get_firebase_uid),
    db: Session = Depends(get_db),
):
    user = get_current_user(firebase_uid, db)
    delivered = send_to_user(
        db, user.id, "Club Ramiro D'Agnone", "Notificación de prueba desde el backend"
    )
    return {"delivered": delivered}