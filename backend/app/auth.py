from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from firebase_admin import auth

# Makes Swagger show an "Authorize" button where a token can be pasted.
bearer_scheme = HTTPBearer()


def get_decoded_token(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> dict:
    """Validates the Firebase ID token and returns its decoded content."""
    try:
        return auth.verify_id_token(credentials.credentials)
    except (ValueError, auth.InvalidIdTokenError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )


def get_firebase_uid(token: dict = Depends(get_decoded_token)) -> str:
    """Returns only the uid of the authenticated user."""
    return token["uid"]