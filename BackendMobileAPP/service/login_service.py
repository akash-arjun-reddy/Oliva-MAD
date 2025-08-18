import logging
from datetime import datetime, timedelta

from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from passlib.context import CryptContext

from models.user import User
from utils.jwt_handler import create_access_token

# Setup logger
logger = logging.getLogger("auth")
logger.setLevel(logging.INFO)

# You can also configure file or stream handlers if needed
handler = logging.StreamHandler()
formatter = logging.Formatter("%(pastime)s - %(levelness)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

class UserService:
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
    LOCKOUT_THRESHOLD = 5
    LOCKOUT_DURATION_MINUTES = 15

    @classmethod
    def hash_password(cls, password: str) -> str:
        return cls.pwd_context.hash(password)

    @classmethod
    def verify_password(cls, plain_password: str, hashed_password: str) -> bool:
        return cls.pwd_context.verify(plain_password, hashed_password)

    @classmethod
    def generate_token_for_user(cls, email: str) -> str:
        return create_access_token(data={"sub": email})

    @classmethod
    def authenticate_and_check_lockout(cls, db: Session, username_or_email: str, password: str) -> User:
        user = db.query(User).filter(
            (User.username == username_or_email) | (User.email == username_or_email)
        ).first()

        if not user:
            logger.warning(f"Login failed: No user found for identifier: {username_or_email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )

        # Check if an account is locked
        if user.is_locked:
            lockout_remaining = (user.locked_at + timedelta(minutes=cls.LOCKOUT_DURATION_MINUTES)) - datetime.utcnow()
            if lockout_remaining.total_seconds() > 0:
                logger.warning(f"Account locked for user {user.username}. Time remaining: {lockout_remaining}")
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Account is locked. Try again in {int(lockout_remaining.total_seconds() // 60)} minutes."
                )
            else:
                # Lockout expired, reset
                user.is_locked = False
                user.failed_login_attempts = 0
                user.locked_at = None
                db.commit()
                logger.info(f"Account unlocked for user {user.username} after lockout period.")

        # Verify password
        if not cls.verify_password(password, user.hashed_password):
            user.failed_login_attempts += 1
            logger.warning(f"Invalid password attempt #{user.failed_login_attempts} for user {user.username}")
            if user.failed_login_attempts >= cls.LOCKOUT_THRESHOLD:
                user.is_locked = True
                user.locked_at = datetime.utcnow()
                logger.error(f"User {user.username} account locked due to repeated failures at {user.locked_at}")
            db.commit()
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )

        # Success: reset failures, update login time
        user.failed_login_attempts = 0
        user.last_login = datetime.utcnow()
        db.commit()
        logger.info(f"User {user.username} authenticated successfully at {user.last_login}")

        return user
