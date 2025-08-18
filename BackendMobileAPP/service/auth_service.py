from fastapi import HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from jose import jwt, JWTError, ExpiredSignatureError
from google.oauth2 import id_token
from google.auth.transport import requests
from typing import Optional, Dict, Any, List
import random
import uuid

from models.otp import OTP
from models.user import User
from models.login_log import LoginLog
from utils.password_utils import get_password_hash, verify_password
from utils.sms_service import send_otp_sms
from utils.email_utils import send_password_reset_email
from dto.otp_dto import (
    SendOTPRequest, VerifyOTPRequest, SignupWithPhoneRequest, ResetPasswordWithOTPRequest
)
from dto.user_login_dto import LoginRequest
from dto.user_register_dto import UserCreate
from dto.user_resetpass_dto import PasswordResetRequest, ResetPasswordBody
from dto.google_auth_dto import OAuthTokenRequest, OAuthUserResponse, OAuthProvider, OAuthUserProfile, \
    OAuthTokenResponse, OAuthLogoutRequest, OAuthSessionInfo
from config import settings

class AuthService:
    TOKEN_EXPIRATION_HOURS = 1

    def __init__(self, db: Session):
        self.db = db

    def _create_token(self, subject: str, expires_hours: int = TOKEN_EXPIRATION_HOURS) -> str:
        """Generate JWT access token."""
        payload = {
            "sub": subject,
            "exp": datetime.utcnow() + timedelta(hours=expires_hours)
        }
        return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

    def register_user(self, user: UserCreate) -> User:
        """Register a new user with email/password."""
        existing_user = self.db.query(User).filter(
            (User.username == user.username) | (User.email == user.email)
        ).first()

        if existing_user:
            raise HTTPException(status_code=400, detail="Username or email already exists")

        hashed_pwd = get_password_hash(user.password)
        new_user = User(**user.dict(exclude={"password"}), hashed_password=hashed_pwd)

        try:
            self.db.add(new_user)
            self.db.commit()
            self.db.refresh(new_user)
            return new_user
        except Exception as e:
            self.db.rollback()
            raise HTTPException(status_code=500, detail="Registration failed")

    def login_user(self, request_id: str, credentials: LoginRequest, ip: str) -> Dict[str, str]:
        """Login user with email/password."""
        user = self.db.query(User).filter(
            (User.username == credentials.login) | (User.email == credentials.login)
        ).first()

        success = user and verify_password(credentials.password, user.hashed_password)
        error_msg = None if success else "Invalid credentials"

        self.db.add(LoginLog(
            request_id=request_id,
            username=credentials.login,
            ip_address=ip,
            success=success,
            error_message=error_msg,
        ))
        self.db.commit()

        if not success:
            raise HTTPException(status_code=401, detail="Invalid credentials")

        try:
            token = self._create_token(user.username)
            return {"access_token": token, "token_type": "bearer"}
        except Exception as e:
            raise HTTPException(status_code=500, detail="Token generation failed")

    def request_password_reset(self, data: PasswordResetRequest) -> dict:
        """Request password reset via email."""
        user = self.db.query(User).filter(User.email == data.email).first()

        if user:
            try:
                token = self._create_token(user.email)
                send_password_reset_email(user.email, token)
            except Exception as e:
                pass

        return {"message": "If the email exists, a reset link has been sent."}

    def reset_password(self, data: ResetPasswordBody) -> dict:
        """Reset password using token."""
        if data.new_password != data.confirm_password:
            raise HTTPException(status_code=400, detail="Passwords do not match")

        try:
            payload = jwt.decode(data.token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
            email = payload.get("sub")
            if not email:
                raise HTTPException(status_code=401, detail="Invalid token")
        except ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="Token expired")
        except JWTError:
            raise HTTPException(status_code=401, detail="Invalid token")

        user = self.db.query(User).filter(User.email == email).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        user.hashed_password = get_password_hash(data.new_password)

        try:
            self.db.commit()
        except Exception as e:
            self.db.rollback()
            raise HTTPException(status_code=500, detail="Failed to reset password")

        return {"message": "Password reset successfully"}

    async def authenticate_oauth(self, request_id: str, token_data: OAuthTokenRequest, ip: str) -> OAuthUserResponse:
        """Authenticate user via OAuth."""
        try:
            if token_data.provider == OAuthProvider.GOOGLE:
                return await self._authenticate_google(request_id, token_data, ip)
            raise HTTPException(status_code=400, detail=f"Unsupported OAuth provider: {token_data.provider}")
        except ValueError as e:
            raise HTTPException(status_code=401, detail="Invalid OAuth token")
        except Exception as e:
            raise HTTPException(status_code=500, detail="OAuth authentication failed")

    async def _authenticate_google(self, request_id: str, token_data: OAuthTokenRequest, ip: str) -> OAuthUserResponse:
        """Authenticate Google OAuth token."""
        idinfo = id_token.verify_oauth2_token(
            token_data.token,
            requests.Request(),
            settings.GOOGLE_CLIENT_ID
        )

        if idinfo['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
            raise ValueError('Invalid issuer')

        oauth_profile = OAuthUserProfile(
            provider=OAuthProvider.GOOGLE,
            provider_user_id=idinfo['sub'],
            email=idinfo['email'],
            email_verified=idinfo.get('email_verified', False),
            name=idinfo.get('name', ''),
            given_name=idinfo.get('given_name'),
            family_name=idinfo.get('family_name'),
            picture=idinfo.get('picture'),
            locale=idinfo.get('locale'),
            updated_at=datetime.utcnow()
        )

        user = self.db.query(User).filter(User.email == oauth_profile.email).first()
        is_new_user = False

        if not user:
            user = User(
                email=oauth_profile.email,
                username=oauth_profile.email.split('@')[0],
                full_name=oauth_profile.name,
                profile_image_url=str(oauth_profile.picture) if oauth_profile.picture else None,
                hashed_password=get_password_hash(''),
                is_active=True
            )

            self.db.add(user)
            self.db.commit()
            self.db.refresh(user)
            is_new_user = True

        self.db.add(LoginLog(
            request_id=request_id,
            username=user.email,
            ip_address=ip,
            success=True,
            error_message=None,
        ))
        self.db.commit()

        access_token = self._create_token(user.username)
        token_response = OAuthTokenResponse(
            access_token=access_token,
            expires_in=self.TOKEN_EXPIRATION_HOURS * 3600,
            token_type="bearer"
        )

        return OAuthUserResponse(
            user=oauth_profile,
            tokens=token_response,
            is_new_user=is_new_user,
            requires_additional_info=False
        )

    async def logout_oauth(self, logout_request: OAuthLogoutRequest) -> Dict[str, Any]:
        """Logout OAuth user."""
        try:
            return {"message": "Successfully logged out"}
        except Exception as e:
            raise HTTPException(status_code=500, detail="Logout failed")

    async def get_oauth_sessions(self, user_id: str) -> List[OAuthSessionInfo]:
        """Get OAuth sessions for user."""
        return []

    def send_otp(self, data: SendOTPRequest) -> dict:
        print(f"🔍 DEBUG: send_otp called with contact_number: {data.contact_number}")
        
        # Normalize phone number (remove + and spaces)
        normalized_number = data.contact_number.replace('+', '').replace(' ', '').replace('-', '')
        print(f"🔍 DEBUG: Normalized phone number: {normalized_number}")
        
        otp_code = ''.join([str(random.randint(0, 9)) for _ in range(6)])
        print(f"🔍 DEBUG: Generated OTP: {otp_code}")
        
        # Mark any existing unused OTPs as used
        self.db.query(OTP).filter(OTP.contact_number == normalized_number, OTP.is_used == False).update({OTP.is_used: True})
        
        # Create new OTP with normalized phone number
        otp = OTP(contact_number=normalized_number, otp_code=otp_code, expires_in_minutes=10)  # Increased to 10 minutes
        self.db.add(otp)
        self.db.commit()
        print(f"🔍 DEBUG: OTP saved to database with number: {normalized_number}")
        print(f"🔍 DEBUG: About to call send_otp_sms with {data.contact_number} and {otp_code}")
        
        sent = send_otp_sms(data.contact_number, otp_code)
        print(f"🔍 DEBUG: send_otp_sms returned: {sent}")
        
        if not sent:
            raise HTTPException(status_code=500, detail="Failed to send OTP")
        return {"message": "OTP sent successfully"}

    def verify_otp(self, data: VerifyOTPRequest) -> dict:
        # Normalize phone number for verification
        normalized_number = data.contact_number.replace('+', '').replace(' ', '').replace('-', '')
        print(f"🔍 DEBUG: verify_otp called with contact_number: {data.contact_number}")
        print(f"🔍 DEBUG: Normalized phone number: {normalized_number}")
        print(f"🔍 DEBUG: OTP code: {data.otp_code}")
        
        otp = self.db.query(OTP).filter(
            OTP.contact_number == normalized_number,
            OTP.otp_code == data.otp_code,
            OTP.is_used == False,
            OTP.expires_at > datetime.utcnow()
        ).first()
        
        if not otp:
            print(f"🔍 DEBUG: No matching OTP found in database")
            print(f"🔍 DEBUG: Checking for any OTPs with this number...")
            all_otps = self.db.query(OTP).filter(OTP.contact_number == normalized_number).all()
            print(f"🔍 DEBUG: Found {len(all_otps)} OTPs for this number:")
            for o in all_otps:
                print(f"🔍 DEBUG: OTP ID: {o.id}, Code: {o.otp_code}, Used: {o.is_used}, Expires: {o.expires_at}")
            raise HTTPException(status_code=400, detail="Invalid or expired OTP")
        
        print(f"🔍 DEBUG: OTP found and verified successfully")
        otp.is_used = True
        self.db.commit()
        return {"message": "OTP verified successfully"}

    def signup_with_phone(self, data: SignupWithPhoneRequest) -> dict:
        # Normalize phone number
        normalized_number = data.contact_number.replace('+', '').replace(' ', '').replace('-', '')
        print(f"🔍 DEBUG: signup_with_phone called with contact_number: {data.contact_number}")
        print(f"🔍 DEBUG: Normalized phone number: {normalized_number}")
        
        otp = self.db.query(OTP).filter(
            OTP.contact_number == normalized_number,
            OTP.otp_code == data.otp_code,
            OTP.is_used == False,
            OTP.expires_at > datetime.utcnow()
        ).first()
        if not otp:
            print(f"🔍 DEBUG: No matching OTP found for signup")
            raise HTTPException(status_code=400, detail="Invalid or expired OTP")
        otp.is_used = True
        existing_user = self.db.query(User).filter(User.contact_number == normalized_number).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="User already exists with this phone number")
        hashed_pwd = get_password_hash(data.password)
        new_user = User(
            username=normalized_number,
            email=f"{normalized_number}@phone.local",
            contact_number=normalized_number,
            hashed_password=hashed_pwd,
            full_name=data.full_name,
            gender=data.gender,
            date_of_birth=data.date_of_birth
        )
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        return {"message": "User created successfully", "user_id": new_user.id}

    def login_with_phone(self, data: SendOTPRequest) -> dict:
        # Normalize phone number
        normalized_number = data.contact_number.replace('+', '').replace(' ', '').replace('-', '')
        print(f"🔍 DEBUG: login_with_phone called with contact_number: {data.contact_number}")
        print(f"🔍 DEBUG: Normalized phone number: {normalized_number}")
        
        user = self.db.query(User).filter(User.contact_number == normalized_number).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return self.send_otp(data)

    def verify_login_otp(self, data: VerifyOTPRequest) -> dict:
        # Normalize phone number
        normalized_number = data.contact_number.replace('+', '').replace(' ', '').replace('-', '')
        print(f"🔍 DEBUG: verify_login_otp called with contact_number: {data.contact_number}")
        print(f"🔍 DEBUG: Normalized phone number: {normalized_number}")
        
        otp = self.db.query(OTP).filter(
            OTP.contact_number == normalized_number,
            OTP.otp_code == data.otp_code,
            OTP.is_used == False,
            OTP.expires_at > datetime.utcnow()
        ).first()
        if not otp:
            print(f"🔍 DEBUG: No matching OTP found for login verification")
            raise HTTPException(status_code=400, detail="Invalid or expired OTP")
        otp.is_used = True
        user = self.db.query(User).filter(User.contact_number == normalized_number).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        token = self._create_token(user.username)
        self.db.commit()
        return {"access_token": token, "token_type": "bearer"}

    def forgot_password_phone(self, data: SendOTPRequest) -> dict:
        user = self.db.query(User).filter(User.contact_number == data.contact_number).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return self.send_otp(data)

    def reset_password_phone(self, data: ResetPasswordWithOTPRequest) -> dict:
        if data.new_password != data.confirm_password:
            raise HTTPException(status_code=400, detail="Passwords do not match")
        otp = self.db.query(OTP).filter(
            OTP.contact_number == data.contact_number,
            OTP.otp_code == data.otp_code,
            OTP.is_used == False,
            OTP.expires_at > datetime.utcnow()
        ).first()
        if not otp:
            raise HTTPException(status_code=400, detail="Invalid or expired OTP")
        otp.is_used = True
        user = self.db.query(User).filter(User.contact_number == data.contact_number).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        user.hashed_password = get_password_hash(data.new_password)
        self.db.commit()
        return {"message": "Password reset successfully"} 