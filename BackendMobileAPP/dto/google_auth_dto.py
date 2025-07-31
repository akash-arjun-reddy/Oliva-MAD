from pydantic import BaseModel, EmailStr, HttpUrl, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class OAuthProvider(str, Enum):
    GOOGLE = "google"
    FACEBOOK = "facebook"
    APPLE = "apple"
    MICROSOFT = "microsoft"

class OAuthTokenType(str, Enum):
    ID_TOKEN = "id_token"
    ACCESS_TOKEN = "access_token"
    REFRESH_TOKEN = "refresh_token"

class OAuthTokenRequest(BaseModel):
    token: str
    token_type: OAuthTokenType = OAuthTokenType.ID_TOKEN
    provider: OAuthProvider = OAuthProvider.GOOGLE
    device_id: Optional[str] = None
    device_name: Optional[str] = None
    device_type: Optional[str] = None

class OAuthUserProfile(BaseModel):
    provider: OAuthProvider
    provider_user_id: str
    email: EmailStr
    email_verified: bool = False
    name: str
    given_name: Optional[str] = None
    family_name: Optional[str] = None
    picture: Optional[HttpUrl] = None
    locale: Optional[str] = None
    phone_number: Optional[str] = None
    phone_number_verified: Optional[bool] = None
    birthdate: Optional[str] = None
    gender: Optional[str] = None
    address: Optional[dict] = None
    updated_at: Optional[datetime] = None

class OAuthError(BaseModel):
    error: str
    error_description: Optional[str] = None
    error_uri: Optional[str] = None
    state: Optional[str] = None

class OAuthTokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    refresh_token: Optional[str] = None
    scope: Optional[List[str]] = None
    id_token: Optional[str] = None

class OAuthUserResponse(BaseModel):
    user: OAuthUserProfile
    tokens: OAuthTokenResponse
    is_new_user: bool = False
    requires_additional_info: bool = False
    required_fields: Optional[List[str]] = None

class OAuthConsentRequest(BaseModel):
    scopes: List[str] = Field(
        default=["email", "profile", "openid"],
        description="List of OAuth scopes requested"
    )
    redirect_uri: str
    state: Optional[str] = None
    nonce: Optional[str] = None
    prompt: Optional[str] = None
    max_age: Optional[int] = None

class OAuthConsentResponse(BaseModel):
    consent_url: str
    state: str
    expires_at: datetime

class OAuthLogoutRequest(BaseModel):
    token: str
    token_type: OAuthTokenType
    provider: OAuthProvider
    device_id: Optional[str] = None
    logout_all_devices: bool = False

class OAuthDeviceInfo(BaseModel):
    device_id: str
    device_name: str
    device_type: str
    last_active: datetime
    ip_address: Optional[str] = None
    location: Optional[str] = None
    is_current_device: bool = False

class OAuthSessionInfo(BaseModel):
    session_id: str
    provider: OAuthProvider
    user_id: str
    created_at: datetime
    expires_at: datetime
    devices: List[OAuthDeviceInfo]
    is_active: bool = True
    last_activity: datetime