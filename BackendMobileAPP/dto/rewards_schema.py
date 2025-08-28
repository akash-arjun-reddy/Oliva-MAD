from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List, Dict, Any
from datetime import datetime, date
from enum import Enum


# ==================== ENUM DEFINITIONS ====================
class AudienceType(str, Enum):
    ALL = "all"
    FIRST_TIME_USERS = "first_time_users"
    LOYALTY_SILVER = "loyalty_silver"
    LOYALTY_GOLD = "loyalty_gold"
    LOYALTY_PLATINUM = "loyalty_platinum"
    NEW_USERS = "new_users"
    RETURNING_USERS = "returning_users"
    VIP_USERS = "vip_users"


class PageType(str, Enum):
    HOME = "home"
    BOOKING = "booking"
    PROFILE = "profile"
    PAYMENT = "payment"
    SHOP = "shop"
    CONSULTATION = "consultation"
    DASHBOARD = "dashboard"
    NOTIFICATIONS = "notifications"


class SectionType(str, Enum):
    BANNER = "banner"
    POPUP = "popup"
    FOOTER = "footer"
    SIDEBAR = "sidebar"
    SUMMARY = "summary"
    HEADER = "header"
    CARD = "card"
    MODAL = "modal"


class RewardType(str, Enum):
    POINTS = "points"
    DISCOUNT = "discount"
    FREE_SERVICE = "free_service"
    GIFT = "gift"
    CASHBACK = "cashback"
    REFERRAL_BONUS = "referral_bonus"
    BIRTHDAY_GIFT = "birthday_gift"
    MILESTONE_REWARD = "milestone_reward"


class OfferType(str, Enum):
    PERCENTAGE_DISCOUNT = "percentage_discount"
    FLAT_DISCOUNT = "flat_discount"
    FREE_SERVICE = "free_service"
    BUY_ONE_GET_ONE = "buy_one_get_one"
    BUNDLE_OFFER = "bundle_offer"
    SEASONAL_OFFER = "seasonal_offer"


class LoyaltyTier(str, Enum):
    BRONZE = "bronze"
    SILVER = "silver"
    GOLD = "gold"
    PLATINUM = "platinum"
    DIAMOND = "diamond"


class StatusType(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    EXPIRED = "expired"
    REDEEMED = "redeemed"
    PENDING = "pending"
    COMPLETED = "completed"


# ==================== BASE MODELS ====================
class BaseRewardModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class BaseResponse(BaseModel):
    success: bool = True
    message: Optional[str] = None
    error: Optional[str] = None


class PaginatedResponse(BaseModel):
    data: List[Any] = []
    pagination: Dict[str, Any] = {}


# ==================== UI CONTENT REQUEST/RESPONSE ====================
class UIContentRequest(BaseModel):
    page: PageType
    section: SectionType
    user_id: Optional[str] = None
    audience: Optional[AudienceType] = AudienceType.ALL
    center_id: Optional[str] = None
    additional_context: Optional[Dict[str, Any]] = None


class Advertisement(BaseModel):
    ad_id: int
    title: str
    image_url: str
    redirect_url: Optional[str] = None
    page: str
    section: str
    audience: str
    priority: int = 1
    center_id: Optional[str] = None
    click_count: int = 0
    view_count: int = 0


class Reward(BaseModel):
    reward_id: int
    name: str
    description: Optional[str] = None
    rule_json: Dict[str, Any]
    page: str
    section: str
    audience: str
    priority: int = 1


class Offer(BaseModel):
    offer_id: int
    title: str
    description: Optional[str] = None
    page: str
    section: str
    audience: str
    conditions_json: Dict[str, Any]
    discount_percentage: Optional[float] = None
    discount_amount: Optional[float] = None
    priority: int = 1


class PersonalizedReward(BaseModel):
    id: int
    user_id: str
    custom_message: Optional[str] = None
    reward_type: Optional[str] = None
    reward_value: Optional[float] = None
    trigger_type: Optional[str] = None


class UIContentResponse(BaseModel):
    advertisements: List[Advertisement] = []
    rewards: List[Reward] = []
    offers: List[Offer] = []
    personalized_rewards: List[PersonalizedReward] = []
    user_loyalty: Optional[Dict[str, Any]] = None


# ==================== REWARDS POINTS SCHEMAS ====================
class RewardsPointsCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None
    rule_json: Dict[str, Any]
    page: str = Field(..., min_length=1, max_length=50)
    section: str = Field(..., min_length=1, max_length=50)
    audience: str = Field(default="all", max_length=100)
    valid_from: date
    valid_till: Optional[date] = None
    priority: int = Field(default=1, ge=1)
    status: StatusType = StatusType.ACTIVE


class RewardsPointsUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    rule_json: Optional[Dict[str, Any]] = None
    page: Optional[str] = Field(None, min_length=1, max_length=50)
    section: Optional[str] = Field(None, min_length=1, max_length=50)
    audience: Optional[str] = Field(None, max_length=100)
    valid_from: Optional[date] = None
    valid_till: Optional[date] = None
    priority: Optional[int] = Field(None, ge=1)
    status: Optional[StatusType] = None


class RewardsPointsResponse(BaseRewardModel):
    reward_id: int
    name: str
    description: Optional[str] = None
    rule_json: Dict[str, Any]
    page: str
    section: str
    audience: str
    valid_from: date
    valid_till: Optional[date] = None
    priority: int
    status: StatusType
    created_at: datetime
    updated_at: datetime


# ==================== REFERRALS SCHEMAS ====================
class ReferralCreate(BaseModel):
    user_id: str = Field(..., max_length=50)
    referred_user_id: str = Field(..., max_length=50)
    reward_points: int = Field(default=0, ge=0)
    discount_amount: float = Field(default=0.0, ge=0.0)
    status: StatusType = StatusType.PENDING


class ReferralUpdate(BaseModel):
    reward_points: Optional[int] = Field(None, ge=0)
    discount_amount: Optional[float] = Field(None, ge=0.0)
    status: Optional[StatusType] = None


class ReferralResponse(BaseRewardModel):
    referral_id: int
    user_id: str
    referred_user_id: str
    reward_points: int
    discount_amount: float
    status: StatusType
    created_at: datetime
    updated_at: datetime


# ==================== LOYALTY TIERS SCHEMAS ====================
class LoyaltyTierCreate(BaseModel):
    tier_name: str = Field(..., min_length=1, max_length=50)
    min_points: int = Field(..., ge=0)
    benefits_json: Dict[str, Any]
    priority: int = Field(default=1, ge=1)
    status: StatusType = StatusType.ACTIVE


class LoyaltyTierUpdate(BaseModel):
    tier_name: Optional[str] = Field(None, min_length=1, max_length=50)
    min_points: Optional[int] = Field(None, ge=0)
    benefits_json: Optional[Dict[str, Any]] = None
    priority: Optional[int] = Field(None, ge=1)
    status: Optional[StatusType] = None


class LoyaltyTierResponse(BaseRewardModel):
    tier_id: int
    tier_name: str
    min_points: int
    benefits_json: Dict[str, Any]
    priority: int
    status: StatusType
    created_at: datetime
    updated_at: datetime


# ==================== JOINING BONUS SCHEMAS ====================
class JoiningBonusCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=100)
    points: int = Field(default=0, ge=0)
    discount_amount: float = Field(default=0.0, ge=0.0)
    audience: str = Field(default="first_time_users", max_length=50)
    valid_from: date
    valid_till: Optional[date] = None
    status: StatusType = StatusType.ACTIVE


class JoiningBonusUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=100)
    points: Optional[int] = Field(None, ge=0)
    discount_amount: Optional[float] = Field(None, ge=0.0)
    audience: Optional[str] = Field(None, max_length=50)
    valid_from: Optional[date] = None
    valid_till: Optional[date] = None
    status: Optional[StatusType] = None


class JoiningBonusResponse(BaseRewardModel):
    bonus_id: int
    title: str
    points: int
    discount_amount: float
    audience: str
    valid_from: date
    valid_till: Optional[date] = None
    status: StatusType
    created_at: datetime
    updated_at: datetime


# ==================== PRIZES & GIFTS SCHEMAS ====================
class PrizeGiftCreate(BaseModel):
    user_id: str = Field(..., max_length=50)
    title: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None
    reward_points: int = Field(default=0, ge=0)
    discount_amount: float = Field(default=0.0, ge=0.0)
    gift_item: Optional[str] = Field(None, max_length=100)
    valid_from: date
    valid_till: Optional[date] = None
    status: StatusType = StatusType.ACTIVE


class PrizeGiftUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    reward_points: Optional[int] = Field(None, ge=0)
    discount_amount: Optional[float] = Field(None, ge=0.0)
    gift_item: Optional[str] = Field(None, max_length=100)
    valid_from: Optional[date] = None
    valid_till: Optional[date] = None
    status: Optional[StatusType] = None


class PrizeGiftResponse(BaseRewardModel):
    gift_id: int
    user_id: str
    title: str
    description: Optional[str] = None
    reward_points: int
    discount_amount: float
    gift_item: Optional[str] = None
    valid_from: date
    valid_till: Optional[date] = None
    status: StatusType
    created_at: datetime
    updated_at: datetime


# ==================== OFFERS & DISCOUNTS SCHEMAS ====================
class OfferDiscountCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None
    page: str = Field(..., min_length=1, max_length=50)
    section: str = Field(..., min_length=1, max_length=50)
    audience: str = Field(default="all", max_length=100)
    conditions_json: Dict[str, Any]
    discount_percentage: Optional[float] = Field(None, ge=0.0, le=100.0)
    discount_amount: Optional[float] = Field(None, ge=0.0)
    valid_from: date
    valid_till: Optional[date] = None
    priority: int = Field(default=1, ge=1)
    status: StatusType = StatusType.ACTIVE


class OfferDiscountUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    page: Optional[str] = Field(None, min_length=1, max_length=50)
    section: Optional[str] = Field(None, min_length=1, max_length=50)
    audience: Optional[str] = Field(None, max_length=100)
    conditions_json: Optional[Dict[str, Any]] = None
    discount_percentage: Optional[float] = Field(None, ge=0.0, le=100.0)
    discount_amount: Optional[float] = Field(None, ge=0.0)
    valid_from: Optional[date] = None
    valid_till: Optional[date] = None
    priority: Optional[int] = Field(None, ge=1)
    status: Optional[StatusType] = None


class OfferDiscountResponse(BaseRewardModel):
    offer_id: int
    title: str
    description: Optional[str] = None
    page: str
    section: str
    audience: str
    conditions_json: Dict[str, Any]
    discount_percentage: Optional[float] = None
    discount_amount: Optional[float] = None
    valid_from: date
    valid_till: Optional[date] = None
    priority: int
    status: StatusType
    created_at: datetime
    updated_at: datetime


# ==================== ADVERTISEMENTS SCHEMAS ====================
class AdvertisementCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=100)
    image_url: str = Field(..., min_length=1, max_length=255)
    redirect_url: Optional[str] = Field(None, max_length=255)
    page: str = Field(..., min_length=1, max_length=50)
    section: str = Field(..., min_length=1, max_length=50)
    audience: str = Field(default="all", max_length=100)
    valid_from: date
    valid_till: Optional[date] = None
    priority: int = Field(default=1, ge=1)
    center_id: Optional[str] = Field(None, max_length=50)
    status: StatusType = StatusType.ACTIVE


class AdvertisementUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=100)
    image_url: Optional[str] = Field(None, min_length=1, max_length=255)
    redirect_url: Optional[str] = Field(None, max_length=255)
    page: Optional[str] = Field(None, min_length=1, max_length=50)
    section: Optional[str] = Field(None, min_length=1, max_length=50)
    audience: Optional[str] = Field(None, max_length=100)
    valid_from: Optional[date] = None
    valid_till: Optional[date] = None
    priority: Optional[int] = Field(None, ge=1)
    center_id: Optional[str] = Field(None, max_length=50)
    status: Optional[StatusType] = None


class AdvertisementResponse(BaseRewardModel):
    ad_id: int
    title: str
    image_url: str
    redirect_url: Optional[str] = None
    page: str
    section: str
    audience: str
    valid_from: date
    valid_till: Optional[date] = None
    priority: int
    center_id: Optional[str] = None
    status: StatusType
    click_count: int
    view_count: int
    created_at: datetime
    updated_at: datetime


# ==================== PERSONALIZED REWARDS SCHEMAS ====================
class PersonalizedRewardCreate(BaseModel):
    user_id: str = Field(..., max_length=50)
    reward_id: Optional[int] = None
    custom_message: Optional[str] = Field(None, max_length=255)
    valid_from: date
    valid_till: Optional[date] = None
    status: StatusType = StatusType.ACTIVE
    reward_type: Optional[str] = Field(None, max_length=50)
    reward_value: Optional[float] = Field(None, ge=0.0)
    trigger_type: Optional[str] = Field(None, max_length=100)


class PersonalizedRewardUpdate(BaseModel):
    custom_message: Optional[str] = Field(None, max_length=255)
    valid_from: Optional[date] = None
    valid_till: Optional[date] = None
    status: Optional[StatusType] = None
    reward_type: Optional[str] = Field(None, max_length=50)
    reward_value: Optional[float] = Field(None, ge=0.0)
    trigger_type: Optional[str] = Field(None, max_length=100)


class PersonalizedRewardResponse(BaseRewardModel):
    id: int
    user_id: str
    reward_id: Optional[int] = None
    custom_message: Optional[str] = None
    valid_from: date
    valid_till: Optional[date] = None
    status: StatusType
    reward_type: Optional[str] = None
    reward_value: Optional[float] = None
    trigger_type: Optional[str] = None
    created_at: datetime
    updated_at: datetime


# ==================== USER LOYALTY SCHEMAS ====================
class UserLoyaltyResponse(BaseRewardModel):
    id: int
    user_id: str
    loyalty_tier: str
    total_points_earned: int
    total_points_redeemed: int
    current_points_balance: int
    points_to_next_tier: int
    tier_upgraded_at: Optional[datetime] = None
    total_bookings: int
    total_spent: float
    last_booking_date: Optional[datetime] = None
    referral_count: int
    created_at: datetime
    updated_at: datetime


# ==================== REWARD TRANSACTIONS SCHEMAS ====================
class RewardTransactionResponse(BaseRewardModel):
    id: int
    user_id: str
    reward_id: Optional[int] = None
    personalized_reward_id: Optional[int] = None
    transaction_type: str
    points_amount: int
    description: Optional[str] = None
    booking_id: Optional[str] = None
    order_id: Optional[str] = None
    points_before: int
    points_after: int
    created_at: datetime


# ==================== FILTER SCHEMAS ====================
class RewardFilter(BaseModel):
    page: Optional[PageType] = None
    section: Optional[SectionType] = None
    audience: Optional[AudienceType] = None
    status: Optional[StatusType] = None
    is_active: Optional[bool] = None
    valid_from: Optional[date] = None
    valid_till: Optional[date] = None


class OfferFilter(BaseModel):
    page: Optional[PageType] = None
    section: Optional[SectionType] = None
    audience: Optional[AudienceType] = None
    status: Optional[StatusType] = None
    is_active: Optional[bool] = None
    service_category: Optional[str] = None
    discount_percentage_min: Optional[float] = None
    discount_percentage_max: Optional[float] = None


class AdFilter(BaseModel):
    page: Optional[PageType] = None
    section: Optional[SectionType] = None
    audience: Optional[AudienceType] = None
    status: Optional[StatusType] = None
    is_active: Optional[bool] = None
    center_id: Optional[str] = None


class ReferralFilter(BaseModel):
    user_id: Optional[str] = None
    status: Optional[StatusType] = None
    created_from: Optional[date] = None
    created_to: Optional[date] = None


# ==================== STATISTICS SCHEMAS ====================
class UserStatistics(BaseModel):
    user_id: str
    loyalty_tier: str
    total_points_earned: int
    total_points_redeemed: int
    current_points_balance: int
    total_bookings: int
    total_spent: float
    referral_count: int
    points_to_next_tier: int


class SystemStatistics(BaseModel):
    total_users: int
    total_rewards_created: int
    total_offers_active: int
    total_ads_active: int
    total_referrals: int
    total_points_awarded: int
    total_points_redeemed: int


# ==================== REQUEST SCHEMAS ====================
class ProcessBookingRewardRequest(BaseModel):
    user_id: str
    booking_id: str
    amount: float = Field(..., ge=0.0)
    service_type: Optional[str] = None


class ProcessReferralRequest(BaseModel):
    user_id: str
    referred_user_id: str
    reward_points: int = Field(default=0, ge=0)
    discount_amount: float = Field(default=0.0, ge=0.0)


class ClaimPersonalizedRewardRequest(BaseModel):
    user_id: str
    personalized_reward_id: int


class RedeemPointsRequest(BaseModel):
    user_id: str
    points_to_redeem: int = Field(..., ge=1)
    description: Optional[str] = None


class IncrementAdStatsRequest(BaseModel):
    ad_id: int
    increment_type: str = Field(..., pattern="^(view|click)$")


# ==================== RESPONSE SCHEMAS ====================
class ProcessBookingRewardResponse(BaseModel):
    success: bool
    points_earned: int
    message: str


class ProcessReferralResponse(BaseModel):
    success: bool
    referral_id: int
    message: str


class ClaimPersonalizedRewardResponse(BaseModel):
    success: bool
    reward_claimed: bool
    message: str


class RedeemPointsResponse(BaseModel):
    success: bool
    points_redeemed: int
    new_balance: int
    message: str


class IncrementAdStatsResponse(BaseModel):
    success: bool
    new_count: int
    message: str


# ==================== ADDITIONAL STATS SCHEMAS ====================
class RewardStats(BaseModel):
    total_rewards: int
    active_rewards: int
    total_points_awarded: int
    total_points_redeemed: int
    average_points_per_user: float


class OfferStats(BaseModel):
    total_offers: int
    active_offers: int
    total_usage: int
    total_discount_value: float


class UserRewardStats(BaseModel):
    user_id: str
    total_points_earned: int
    total_points_redeemed: int
    current_balance: int
    loyalty_tier: str
    total_rewards_claimed: int
    total_offers_used: int
