from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc, asc, func
from typing import List, Optional, Dict, Any
from datetime import datetime, date
from models.rewards_models import (
    RewardsPoints, Referrals, LoyaltyTiers, JoiningBonus, PrizesGifts,
    OffersDiscounts, Advertisements, PersonalizedRewards, UserLoyalty,
    RewardTransactions, OfferUsage, UserRewardClaims, RewardRules,
    LoyaltyTierBenefits, StatusType
)
from dto.rewards_schema import (
    RewardFilter, OfferFilter, AdFilter, PageType, SectionType, AudienceType
)
from utils.logger import get_logger

logger = get_logger()


class RewardsRepository:
    def __init__(self, db: Session):
        self.db = db

    # ==================== REWARDS POINTS OPERATIONS ====================
    
    def create_reward(self, reward_data: Dict[str, Any]) -> RewardsPoints:
        """Create a new reward"""
        try:
            reward = RewardsPoints(**reward_data)
            self.db.add(reward)
            self.db.commit()
            self.db.refresh(reward)
            logger.info(f"Created reward: {reward.reward_id}")
            return reward
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating reward: {e}")
            raise

    def get_reward_by_id(self, reward_id: int) -> Optional[RewardsPoints]:
        """Get reward by ID"""
        return self.db.query(RewardsPoints).filter(RewardsPoints.reward_id == reward_id).first()

    def get_rewards_by_filter(self, filter_data: RewardFilter, page: int = 1, size: int = 20) -> tuple:
        """Get rewards with filtering and pagination"""
        query = self.db.query(RewardsPoints)
        
        # Apply filters
        if filter_data.page:
            query = query.filter(RewardsPoints.page == filter_data.page.value)
        if filter_data.section:
            query = query.filter(RewardsPoints.section == filter_data.section.value)
        if filter_data.audience:
            query = query.filter(RewardsPoints.audience == filter_data.audience.value)
        if filter_data.is_active is not None:
            query = query.filter(RewardsPoints.status == StatusType.ACTIVE if filter_data.is_active else StatusType.INACTIVE)
        
        # Apply date filters
        today = date.today()
        query = query.filter(
            and_(
                RewardsPoints.valid_from <= today,
                or_(RewardsPoints.valid_till.is_(None), RewardsPoints.valid_till >= today)
            )
        )
        
        # Count total
        total = query.count()
        
        # Apply pagination and ordering
        rewards = query.order_by(desc(RewardsPoints.priority), desc(RewardsPoints.created_at))\
                      .offset((page - 1) * size).limit(size).all()
        
        return rewards, total

    def update_reward(self, reward_id: int, update_data: Dict[str, Any]) -> Optional[RewardsPoints]:
        """Update reward"""
        try:
            reward = self.get_reward_by_id(reward_id)
            if not reward:
                return None
            
            for key, value in update_data.items():
                if hasattr(reward, key):
                    setattr(reward, key, value)
            
            reward.updated_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(reward)
            logger.info(f"Updated reward: {reward_id}")
            return reward
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error updating reward: {e}")
            raise

    def delete_reward(self, reward_id: int) -> bool:
        """Soft delete reward"""
        try:
            reward = self.get_reward_by_id(reward_id)
            if not reward:
                return False
            
            reward.status = StatusType.INACTIVE
            reward.updated_at = datetime.utcnow()
            self.db.commit()
            logger.info(f"Deleted reward: {reward_id}")
            return True
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error deleting reward: {e}")
            raise

    # ==================== OFFERS OPERATIONS ====================
    
    def create_offer(self, offer_data: Dict[str, Any]) -> OffersDiscounts:
        """Create a new offer"""
        try:
            offer = OffersDiscounts(**offer_data)
            self.db.add(offer)
            self.db.commit()
            self.db.refresh(offer)
            logger.info(f"Created offer: {offer.offer_id}")
            return offer
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating offer: {e}")
            raise

    def get_offer_by_id(self, offer_id: int) -> Optional[OffersDiscounts]:
        """Get offer by ID"""
        return self.db.query(OffersDiscounts).filter(OffersDiscounts.offer_id == offer_id).first()

    def get_offers_by_filter(self, filter_data: OfferFilter, page: int = 1, size: int = 20) -> tuple:
        """Get offers with filtering and pagination"""
        query = self.db.query(OffersDiscounts)
        
        # Apply filters
        if filter_data.page:
            query = query.filter(OffersDiscounts.page == filter_data.page.value)
        if filter_data.section:
            query = query.filter(OffersDiscounts.section == filter_data.section.value)
        if filter_data.audience:
            query = query.filter(OffersDiscounts.audience == filter_data.audience.value)
        if filter_data.service_category:
            query = query.filter(OffersDiscounts.conditions_json.contains({"service": filter_data.service_category}))
        if filter_data.is_active is not None:
            query = query.filter(OffersDiscounts.status == StatusType.ACTIVE if filter_data.is_active else StatusType.INACTIVE)
        
        # Apply date filters
        today = date.today()
        query = query.filter(
            and_(
                OffersDiscounts.valid_from <= today,
                or_(OffersDiscounts.valid_till.is_(None), OffersDiscounts.valid_till >= today)
            )
        )
        
        # Count total
        total = query.count()
        
        # Apply pagination and ordering
        offers = query.order_by(desc(OffersDiscounts.priority), desc(OffersDiscounts.created_at))\
                     .offset((page - 1) * size).limit(size).all()
        
        return offers, total

    def update_offer(self, offer_id: int, update_data: Dict[str, Any]) -> Optional[OffersDiscounts]:
        """Update offer"""
        try:
            offer = self.get_offer_by_id(offer_id)
            if not offer:
                return None
            
            for key, value in update_data.items():
                if hasattr(offer, key):
                    setattr(offer, key, value)
            
            offer.updated_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(offer)
            logger.info(f"Updated offer: {offer_id}")
            return offer
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error updating offer: {e}")
            raise

    # ==================== ADVERTISEMENTS OPERATIONS ====================
    
    def create_advertisement(self, ad_data: Dict[str, Any]) -> Advertisements:
        """Create a new advertisement"""
        try:
            ad = Advertisements(**ad_data)
            self.db.add(ad)
            self.db.commit()
            self.db.refresh(ad)
            logger.info(f"Created advertisement: {ad.ad_id}")
            return ad
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating advertisement: {e}")
            raise

    def get_advertisement_by_id(self, ad_id: int) -> Optional[Advertisements]:
        """Get advertisement by ID"""
        return self.db.query(Advertisements).filter(Advertisements.ad_id == ad_id).first()

    def get_advertisements_by_filter(self, filter_data: AdFilter, page: int = 1, size: int = 20) -> tuple:
        """Get advertisements with filtering and pagination"""
        query = self.db.query(Advertisements)
        
        # Apply filters
        if filter_data.page:
            query = query.filter(Advertisements.page == filter_data.page.value)
        if filter_data.section:
            query = query.filter(Advertisements.section == filter_data.section.value)
        if filter_data.audience:
            query = query.filter(Advertisements.audience == filter_data.audience.value)
        if filter_data.is_active is not None:
            query = query.filter(Advertisements.status == StatusType.ACTIVE if filter_data.is_active else StatusType.INACTIVE)
        
        # Apply date filters
        today = date.today()
        query = query.filter(
            and_(
                Advertisements.valid_from <= today,
                or_(Advertisements.valid_till.is_(None), Advertisements.valid_till >= today)
            )
        )
        
        # Count total
        total = query.count()
        
        # Apply pagination and ordering
        ads = query.order_by(desc(Advertisements.priority), desc(Advertisements.created_at))\
                  .offset((page - 1) * size).limit(size).all()
        
        return ads, total

    def increment_ad_views(self, ad_id: int) -> bool:
        """Increment advertisement view count"""
        try:
            ad = self.get_advertisement_by_id(ad_id)
            if ad:
                ad.view_count += 1
                self.db.commit()
                return True
            return False
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error incrementing ad views: {e}")
            raise

    def increment_ad_clicks(self, ad_id: int) -> bool:
        """Increment advertisement click count"""
        try:
            ad = self.get_advertisement_by_id(ad_id)
            if ad:
                ad.click_count += 1
                self.db.commit()
                return True
            return False
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error incrementing ad clicks: {e}")
            raise

    # ==================== USER LOYALTY OPERATIONS ====================
    
    def get_user_loyalty(self, user_id: str) -> Optional[UserLoyalty]:
        """Get user loyalty information"""
        return self.db.query(UserLoyalty).filter(UserLoyalty.user_id == user_id).first()

    def create_user_loyalty(self, user_id: str) -> UserLoyalty:
        """Create user loyalty record"""
        try:
            loyalty = UserLoyalty(user_id=user_id)
            self.db.add(loyalty)
            self.db.commit()
            self.db.refresh(loyalty)
            logger.info(f"Created user loyalty for: {user_id}")
            return loyalty
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating user loyalty: {e}")
            raise

    def update_user_points(self, user_id: str, points_to_add: int, transaction_type: str, 
                          description: str = None, booking_id: str = None) -> bool:
        """Update user points and create transaction record"""
        try:
            loyalty = self.get_user_loyalty(user_id)
            if not loyalty:
                loyalty = self.create_user_loyalty(user_id)
            
            points_before = loyalty.current_points_balance
            loyalty.current_points_balance += points_to_add
            loyalty.total_points_earned += points_to_add
            loyalty.updated_at = datetime.utcnow()
            
            # Create transaction record
            transaction = RewardTransactions(
                user_id=user_id,
                transaction_type=transaction_type,
                points_amount=points_to_add,
                description=description,
                booking_id=booking_id,
                points_before=points_before,
                points_after=loyalty.current_points_balance
            )
            self.db.add(transaction)
            
            self.db.commit()
            logger.info(f"Updated points for user {user_id}: +{points_to_add}")
            return True
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error updating user points: {e}")
            raise

    def redeem_user_points(self, user_id: str, points_to_redeem: int, 
                          description: str = None, booking_id: str = None) -> bool:
        """Redeem user points"""
        try:
            loyalty = self.get_user_loyalty(user_id)
            if not loyalty or loyalty.current_points_balance < points_to_redeem:
                return False
            
            points_before = loyalty.current_points_balance
            loyalty.current_points_balance -= points_to_redeem
            loyalty.total_points_redeemed += points_to_redeem
            loyalty.updated_at = datetime.utcnow()
            
            # Create transaction record
            transaction = RewardTransactions(
                user_id=user_id,
                transaction_type="redeemed",
                points_amount=-points_to_redeem,
                description=description,
                booking_id=booking_id,
                points_before=points_before,
                points_after=loyalty.current_points_balance
            )
            self.db.add(transaction)
            
            self.db.commit()
            logger.info(f"Redeemed points for user {user_id}: -{points_to_redeem}")
            return True
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error redeeming user points: {e}")
            raise

    # ==================== REFERRAL OPERATIONS ====================
    
    def create_referral(self, referrer_id: str, referred_user_id: str, 
                       reward_points: int = 0, discount_amount: float = 0.0) -> Referrals:
        """Create a new referral"""
        try:
            referral = Referrals(
                user_id=referrer_id,
                referred_user_id=referred_user_id,
                reward_points=reward_points,
                discount_amount=discount_amount
            )
            self.db.add(referral)
            self.db.commit()
            self.db.refresh(referral)
            logger.info(f"Created referral: {referral.referral_id}")
            return referral
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating referral: {e}")
            raise

    def get_user_referrals(self, user_id: str) -> List[Referrals]:
        """Get all referrals for a user"""
        return self.db.query(Referrals).filter(Referrals.user_id == user_id).all()

    def update_referral_status(self, referral_id: int, status: StatusType) -> bool:
        """Update referral status"""
        try:
            referral = self.db.query(Referrals).filter(Referrals.referral_id == referral_id).first()
            if not referral:
                return False
            
            referral.status = status
            referral.updated_at = datetime.utcnow()
            self.db.commit()
            logger.info(f"Updated referral status: {referral_id} -> {status}")
            return True
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error updating referral status: {e}")
            raise

    # ==================== PERSONALIZED REWARDS OPERATIONS ====================
    
    def create_personalized_reward(self, reward_data: Dict[str, Any]) -> PersonalizedRewards:
        """Create a personalized reward"""
        try:
            reward = PersonalizedRewards(**reward_data)
            self.db.add(reward)
            self.db.commit()
            self.db.refresh(reward)
            logger.info(f"Created personalized reward: {reward.id}")
            return reward
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating personalized reward: {e}")
            raise

    def get_user_personalized_rewards(self, user_id: str, unclaimed_only: bool = True) -> List[PersonalizedRewards]:
        """Get personalized rewards for a user"""
        query = self.db.query(PersonalizedRewards).filter(PersonalizedRewards.user_id == user_id)
        
        if unclaimed_only:
            query = query.filter(PersonalizedRewards.status == StatusType.ACTIVE)
        
        # Apply date filters
        today = date.today()
        query = query.filter(
            and_(
                PersonalizedRewards.valid_from <= today,
                or_(PersonalizedRewards.valid_till.is_(None), PersonalizedRewards.valid_till >= today)
            )
        )
        
        return query.order_by(desc(PersonalizedRewards.created_at)).all()

    def claim_personalized_reward(self, reward_id: int, user_id: str) -> bool:
        """Claim a personalized reward"""
        try:
            reward = self.db.query(PersonalizedRewards).filter(
                and_(
                    PersonalizedRewards.id == reward_id,
                    PersonalizedRewards.user_id == user_id,
                    PersonalizedRewards.status == StatusType.ACTIVE
                )
            ).first()
            
            if not reward:
                return False
            
            reward.status = StatusType.REDEEMED
            reward.updated_at = datetime.utcnow()
            
            # Create claim record
            claim = UserRewardClaims(
                user_id=user_id,
                reward_type="personalized",
                reward_id=reward_id,
                points_earned=reward.reward_value if reward.reward_type == "points" else 0,
                discount_earned=reward.reward_value if reward.reward_type == "discount" else 0.0
            )
            self.db.add(claim)
            
            self.db.commit()
            logger.info(f"Claimed personalized reward: {reward_id}")
            return True
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error claiming personalized reward: {e}")
            raise

    # ==================== LOYALTY TIERS OPERATIONS ====================
    
    def get_loyalty_tiers(self) -> List[LoyaltyTiers]:
        """Get all active loyalty tiers"""
        return self.db.query(LoyaltyTiers).filter(LoyaltyTiers.status == StatusType.ACTIVE)\
                     .order_by(LoyaltyTiers.priority).all()

    def get_next_tier(self, current_points: int) -> Optional[LoyaltyTiers]:
        """Get the next tier based on current points"""
        return self.db.query(LoyaltyTiers).filter(
            and_(
                LoyaltyTiers.min_points > current_points,
                LoyaltyTiers.status == StatusType.ACTIVE
            )
        ).order_by(LoyaltyTiers.min_points).first()

    def update_user_tier(self, user_id: str, new_tier: str) -> bool:
        """Update user loyalty tier"""
        try:
            loyalty = self.get_user_loyalty(user_id)
            if not loyalty:
                return False
            
            loyalty.loyalty_tier = new_tier
            loyalty.tier_upgraded_at = datetime.utcnow()
            loyalty.updated_at = datetime.utcnow()
            
            self.db.commit()
            logger.info(f"Updated user tier: {user_id} -> {new_tier}")
            return True
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error updating user tier: {e}")
            raise

    # ==================== OFFER USAGE OPERATIONS ====================
    
    def record_offer_usage(self, user_id: str, offer_id: int, 
                          booking_id: str = None, discount_applied: float = 0.0) -> OfferUsage:
        """Record offer usage"""
        try:
            usage = OfferUsage(
                user_id=user_id,
                offer_id=offer_id,
                booking_id=booking_id,
                discount_applied=discount_applied
            )
            self.db.add(usage)
            self.db.commit()
            self.db.refresh(usage)
            logger.info(f"Recorded offer usage: {usage.id}")
            return usage
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error recording offer usage: {e}")
            raise

    def get_user_offer_usage_count(self, user_id: str, offer_id: int) -> int:
        """Get count of times user has used an offer"""
        return self.db.query(OfferUsage).filter(
            and_(
                OfferUsage.user_id == user_id,
                OfferUsage.offer_id == offer_id
            )
        ).count()

    # ==================== REWARD RULES OPERATIONS ====================
    
    def get_active_reward_rules(self, rule_type: str = None) -> List[RewardRules]:
        """Get active reward rules"""
        query = self.db.query(RewardRules).filter(RewardRules.is_active == True)
        
        if rule_type:
            query = query.filter(RewardRules.rule_type == rule_type)
        
        return query.order_by(RewardRules.priority).all()

    def evaluate_reward_rules(self, user_id: str, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Evaluate reward rules based on context"""
        rules = self.get_active_reward_rules()
        applicable_rewards = []
        
        for rule in rules:
            # Simple rule evaluation - can be enhanced with more complex logic
            conditions = rule.conditions_json
            is_applicable = True
            
            # Check if user meets conditions
            if "minAmount" in conditions and context.get("amount", 0) < conditions["minAmount"]:
                is_applicable = False
            
            if "serviceCategory" in conditions and context.get("service_category") != conditions["serviceCategory"]:
                is_applicable = False
            
            if is_applicable:
                applicable_rewards.append({
                    "rule_id": rule.id,
                    "rule_name": rule.rule_name,
                    "reward": rule.reward_json
                })
        
        return applicable_rewards

    # ==================== STATISTICS OPERATIONS ====================
    
    def get_reward_statistics(self) -> Dict[str, Any]:
        """Get reward system statistics"""
        try:
            total_rewards = self.db.query(RewardsPoints).count()
            active_rewards = self.db.query(RewardsPoints).filter(RewardsPoints.status == StatusType.ACTIVE).count()
            
            total_points_issued = self.db.query(func.sum(RewardTransactions.points_amount))\
                                        .filter(RewardTransactions.transaction_type == "earned").scalar() or 0
            
            total_points_redeemed = abs(self.db.query(func.sum(RewardTransactions.points_amount))\
                                      .filter(RewardTransactions.transaction_type == "redeemed").scalar() or 0)
            
            return {
                "total_rewards": total_rewards,
                "active_rewards": active_rewards,
                "total_points_issued": total_points_issued,
                "total_points_redeemed": total_points_redeemed
            }
        except Exception as e:
            logger.error(f"Error getting reward statistics: {e}")
            return {}

    def get_user_reward_statistics(self, user_id: str) -> Dict[str, Any]:
        """Get user-specific reward statistics"""
        try:
            loyalty = self.get_user_loyalty(user_id)
            if not loyalty:
                return {}
            
            unclaimed_rewards = len(self.get_user_personalized_rewards(user_id, unclaimed_only=True))
            
            return {
                "user_id": user_id,
                "loyalty_tier": loyalty.loyalty_tier,
                "current_points": loyalty.current_points_balance,
                "total_earned": loyalty.total_points_earned,
                "total_redeemed": loyalty.total_points_redeemed,
                "total_bookings": loyalty.total_bookings,
                "total_spent": float(loyalty.total_spent),
                "unclaimed_rewards": unclaimed_rewards
            }
        except Exception as e:
            logger.error(f"Error getting user reward statistics: {e}")
            return {}
