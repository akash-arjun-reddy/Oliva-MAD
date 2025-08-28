from sqlalchemy import Column, Integer, String, Boolean, Date, DateTime, Float, Text, JSON, ForeignKey, Enum, DECIMAL
from sqlalchemy.dialects.postgresql import ENUM
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from database.base import Base


class AudienceType(enum.Enum):
    ALL = "all"
    FIRST_TIME_USERS = "first_time_users"
    LOYALTY_SILVER = "loyalty_silver"
    LOYALTY_GOLD = "loyalty_gold"
    LOYALTY_PLATINUM = "loyalty_platinum"
    NEW_USERS = "new_users"
    RETURNING_USERS = "returning_users"
    VIP_USERS = "vip_users"


class PageType(enum.Enum):
    HOME = "home"
    BOOKING = "booking"
    PROFILE = "profile"
    PAYMENT = "payment"
    SHOP = "shop"
    CONSULTATION = "consultation"
    DASHBOARD = "dashboard"
    NOTIFICATIONS = "notifications"


class SectionType(enum.Enum):
    BANNER = "banner"
    POPUP = "popup"
    FOOTER = "footer"
    SIDEBAR = "sidebar"
    SUMMARY = "summary"
    HEADER = "header"
    CARD = "card"
    MODAL = "modal"


class RewardType(enum.Enum):
    POINTS = "points"
    DISCOUNT = "discount"
    FREE_SERVICE = "free_service"
    GIFT = "gift"
    CASHBACK = "cashback"
    REFERRAL_BONUS = "referral_bonus"
    BIRTHDAY_GIFT = "birthday_gift"
    MILESTONE_REWARD = "milestone_reward"


class OfferType(enum.Enum):
    PERCENTAGE_DISCOUNT = "percentage_discount"
    FLAT_DISCOUNT = "flat_discount"
    FREE_SERVICE = "free_service"
    BUY_ONE_GET_ONE = "buy_one_get_one"
    BUNDLE_OFFER = "bundle_offer"
    SEASONAL_OFFER = "seasonal_offer"


class LoyaltyTier(enum.Enum):
    BRONZE = "bronze"
    SILVER = "silver"
    GOLD = "gold"
    PLATINUM = "platinum"
    DIAMOND = "diamond"


class StatusType(enum.Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    EXPIRED = "expired"
    REDEEMED = "redeemed"
    PENDING = "pending"
    COMPLETED = "completed"


# ==================== REWARDS POINTS TABLE ====================
class RewardsPoints(Base):
    __tablename__ = "rewards_points"
    
    reward_id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    rule_json = Column(JSON, nullable=False)  # {"perSpend": 10, "minAmount": 500}
    page = Column(String(50), nullable=False)
    section = Column(String(50), nullable=False)
    audience = Column(String(100), nullable=False, default="all")
    valid_from = Column(Date, nullable=False)
    valid_till = Column(Date, nullable=True)
    priority = Column(Integer, default=1)
    status = Column(ENUM('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), default='active')
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== REFERRALS TABLE ====================
class Referrals(Base):
    __tablename__ = "referrals"
    
    referral_id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_id = Column(String(50), nullable=False)  # inviter
    referred_user_id = Column(String(50), nullable=False)  # friend invited
    reward_points = Column(Integer, default=0)  # bonus points given
    discount_amount = Column(DECIMAL(10, 2), default=0.0)  # optional flat discount
    status = Column(ENUM('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), default='pending')
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== LOYALTY TIERS TABLE ====================
class LoyaltyTiers(Base):
    __tablename__ = "loyalty_tiers"
    
    tier_id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    tier_name = Column(String(50), nullable=False)  # Silver, Gold, Platinum
    min_points = Column(Integer, nullable=False)  # threshold to unlock
    benefits_json = Column(JSON, nullable=False)  # {"discount":5, "priority_booking":true}
    priority = Column(Integer, default=1)  # tier rank
    status = Column(ENUM('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), default='active')
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== JOINING BONUS TABLE ====================
class JoiningBonus(Base):
    __tablename__ = "joining_bonus"
    
    bonus_id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    title = Column(String(100), nullable=False)  # e.g., Welcome Bonus
    points = Column(Integer, default=0)  # e.g., 100 points
    discount_amount = Column(DECIMAL(10, 2), default=0.0)  # e.g., 200 INR flat discount
    audience = Column(String(50), default="first_time_users")
    valid_from = Column(Date, nullable=False)
    valid_till = Column(Date, nullable=True)
    status = Column(ENUM('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), default='active')
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== PRIZES & GIFTS TABLE ====================
class PrizesGifts(Base):
    __tablename__ = "prizes_gifts"
    
    gift_id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_id = Column(String(50), nullable=False)  # personalized
    title = Column(String(100), nullable=False)  # e.g., Birthday Gift, 10th Visit Prize
    description = Column(Text, nullable=True)
    reward_points = Column(Integer, default=0)
    discount_amount = Column(DECIMAL(10, 2), default=0.0)
    gift_item = Column(String(100), nullable=True)  # e.g., Free Cream, Voucher Code
    valid_from = Column(Date, nullable=False)
    valid_till = Column(Date, nullable=True)
    status = Column(ENUM('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), default='active')
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== OFFERS & DISCOUNTS TABLE ====================
class OffersDiscounts(Base):
    __tablename__ = "offers_discounts"
    
    offer_id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    title = Column(String(100), nullable=False)  # e.g., 20% Hair Care
    description = Column(Text, nullable=True)
    page = Column(String(50), nullable=False)  # home, booking, payment
    section = Column(String(50), nullable=False)  # footer, popup, banner
    audience = Column(String(100), nullable=False, default="all")  # all, first_time_users, loyalty_gold
    conditions_json = Column(JSON, nullable=False)  # {"service": "hair", "minAmount": 500}
    discount_percentage = Column(DECIMAL(5, 2), default=0.0)
    discount_amount = Column(DECIMAL(10, 2), default=0.0)
    valid_from = Column(Date, nullable=False)
    valid_till = Column(Date, nullable=True)
    priority = Column(Integer, default=1)
    status = Column(ENUM('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), default='active')
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== ADVERTISEMENTS TABLE ====================
class Advertisements(Base):
    __tablename__ = "ads"
    
    ad_id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    title = Column(String(100), nullable=False)
    image_url = Column(String(255), nullable=False)
    redirect_url = Column(String(255), nullable=True)
    page = Column(String(50), nullable=False)  # home, booking, profile, payment
    section = Column(String(50), nullable=False)  # banner, popup, footer
    audience = Column(String(100), nullable=False, default="all")  # all, loyalty_gold, first_time_users
    valid_from = Column(Date, nullable=False)
    valid_till = Column(Date, nullable=True)
    priority = Column(Integer, default=1)
    center_id = Column(String(50), nullable=True)  # optional, branch-specific
    status = Column(ENUM('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), default='active')
    
    # Analytics fields
    click_count = Column(Integer, default=0)
    view_count = Column(Integer, default=0)
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== PERSONALIZED REWARDS TABLE ====================
class PersonalizedRewards(Base):
    __tablename__ = "personalized_rewards"
    
    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_id = Column(String(50), nullable=False)
    reward_id = Column(Integer, ForeignKey("rewards_points.reward_id"), nullable=True)  # link to rewards_points
    custom_message = Column(String(255), nullable=True)  # "Free Skin Cream 🎁"
    valid_from = Column(Date, nullable=False)
    valid_till = Column(Date, nullable=True)
    status = Column(ENUM('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), default='active')
    
    # Additional fields for enhanced functionality
    reward_type = Column(String(50), nullable=True)  # points, discount, gift
    reward_value = Column(DECIMAL(10, 2), default=0.0)
    trigger_type = Column(String(100), nullable=True)  # birthday, milestone, special_occasion
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== USER LOYALTY EXTENSIONS ====================
class UserLoyalty(Base):
    __tablename__ = "user_loyalty"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(50), unique=True, nullable=False)
    
    # Loyalty tier and points
    loyalty_tier = Column(String(50), default="bronze")
    total_points_earned = Column(Integer, default=0)
    total_points_redeemed = Column(Integer, default=0)
    current_points_balance = Column(Integer, default=0)
    
    # Tier progression
    points_to_next_tier = Column(Integer, default=0)
    tier_upgraded_at = Column(DateTime, nullable=True)
    
    # Engagement metrics
    total_bookings = Column(Integer, default=0)
    total_spent = Column(DECIMAL(10, 2), default=0.0)
    last_booking_date = Column(DateTime, nullable=True)
    referral_count = Column(Integer, default=0)
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== REWARD TRANSACTIONS ====================
class RewardTransactions(Base):
    __tablename__ = "reward_transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(50), nullable=False)
    reward_id = Column(Integer, ForeignKey("rewards_points.reward_id"), nullable=True)
    personalized_reward_id = Column(Integer, ForeignKey("personalized_rewards.id"), nullable=True)
    
    # Transaction details
    transaction_type = Column(String(50), nullable=False)  # earned, redeemed, expired, bonus
    points_amount = Column(Integer, default=0)
    description = Column(Text, nullable=True)
    
    # Related booking/order
    booking_id = Column(String(100), nullable=True)
    order_id = Column(String(100), nullable=True)
    
    # Balance tracking
    points_before = Column(Integer, default=0)
    points_after = Column(Integer, default=0)
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)


# ==================== OFFER USAGE TRACKING ====================
class OfferUsage(Base):
    __tablename__ = "offer_usages"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(50), nullable=False)
    offer_id = Column(Integer, ForeignKey("offers_discounts.offer_id"), nullable=False)
    
    # Usage details
    booking_id = Column(String(100), nullable=True)
    order_id = Column(String(100), nullable=True)
    discount_applied = Column(DECIMAL(10, 2), default=0.0)
    
    # Audit fields
    used_at = Column(DateTime, default=datetime.utcnow)


# ==================== USER REWARD CLAIMS ====================
class UserRewardClaims(Base):
    __tablename__ = "user_reward_claims"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(50), nullable=False)
    reward_type = Column(String(50), nullable=False)  # joining_bonus, prize_gift, personalized
    reward_id = Column(Integer, nullable=True)  # ID from respective table
    claimed_at = Column(DateTime, default=datetime.utcnow)
    points_earned = Column(Integer, default=0)
    discount_earned = Column(DECIMAL(10, 2), default=0.0)
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)


# ==================== REWARD RULES ENGINE ====================
class RewardRules(Base):
    __tablename__ = "reward_rules"
    
    id = Column(Integer, primary_key=True, index=True)
    rule_name = Column(String(100), nullable=False)
    rule_type = Column(String(50), nullable=False)  # booking, spend, referral, milestone
    conditions_json = Column(JSON, nullable=False)  # {"minAmount": 500, "serviceCategory": "hair"}
    reward_json = Column(JSON, nullable=False)  # {"points": 10, "discount": 5}
    priority = Column(Integer, default=1)
    is_active = Column(Boolean, default=True)
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# ==================== LOYALTY TIER BENEFITS ====================
class LoyaltyTierBenefits(Base):
    __tablename__ = "loyalty_tier_benefits"
    
    id = Column(Integer, primary_key=True, index=True)
    tier_name = Column(String(50), nullable=False)
    benefit_type = Column(String(50), nullable=False)  # discount, priority, free_service
    benefit_value = Column(String(255), nullable=False)  # "10%", "true", "skin_check"
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    
    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
