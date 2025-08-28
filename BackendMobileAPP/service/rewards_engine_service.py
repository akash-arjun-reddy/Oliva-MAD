from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from datetime import datetime, date
from repository.rewards_repository import RewardsRepository
from dto.rewards_schema import (
    UIContentRequest, UIContentResponse, UserLoyaltyResponse,
    PageType, SectionType, AudienceType, StatusType
)
from models.rewards_models import StatusType as ModelStatusType
from utils.logger import get_logger

logger = get_logger()


class RewardsEngineService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = RewardsRepository(db)

    # ==================== CORE REWARD ENGINE ====================
    
    def get_ui_content(self, request: UIContentRequest) -> UIContentResponse:
        """
        Main method to get dynamic UI content for mobile app
        This is the core method that the mobile app calls
        """
        try:
            logger.info(f"Getting UI content for user {request.user_id} on {request.page}.{request.section}")
            
            # Get user loyalty information
            user_loyalty = self._get_user_loyalty_info(request.user_id)
            
            # Determine user audience type
            audience_type = self._determine_user_audience(request.user_id, user_loyalty)
            
            # Get content based on page, section, and audience
            ads = self._get_ads_for_page(request.page, request.section, audience_type)
            rewards = self._get_rewards_for_page(request.page, request.section, audience_type)
            offers = self._get_offers_for_page(request.page, request.section, audience_type, request.user_id)
            personalized_rewards = self._get_personalized_rewards(request.user_id)
            
            # Apply additional context if provided
            if request.additional_context:
                self._apply_context_filters(ads, rewards, offers, request.additional_context)
            
            return UIContentResponse(
                advertisements=ads,
                rewards=rewards,
                offers=offers,
                personalized_rewards=personalized_rewards,
                user_loyalty=user_loyalty
            )
            
        except Exception as e:
            logger.error(f"Error getting UI content: {e}")
            return UIContentResponse()

    def process_booking_reward(self, user_id: str, booking_amount: float, 
                              booking_id: str, service_category: str = None) -> Dict[str, Any]:
        """
        Process rewards when a booking is completed
        """
        try:
            logger.info(f"Processing booking reward for user {user_id}, amount: {booking_amount}")
            
            # Get applicable reward rules
            context = {
                "amount": booking_amount,
                "service_category": service_category,
                "booking_id": booking_id
            }
            
            applicable_rewards = self.repository.evaluate_reward_rules(user_id, context)
            
            total_points_earned = 0
            rewards_given = []
            
            for reward_info in applicable_rewards:
                reward = reward_info["reward"]
                points = reward.get("points", 0)
                
                if points > 0:
                    # Update user points
                    success = self.repository.update_user_points(
                        user_id=user_id,
                        points_to_add=points,
                        transaction_type="earned",
                        description=f"Booking reward: {reward_info['rule_name']}",
                        booking_id=booking_id
                    )
                    
                    if success:
                        total_points_earned += points
                        rewards_given.append({
                            "rule_name": reward_info["rule_name"],
                            "points": points,
                            "type": "points"
                        })
            
            # Check for tier upgrades
            self._check_and_process_tier_upgrade(user_id)
            
            return {
                "success": True,
                "total_points_earned": total_points_earned,
                "rewards_given": rewards_given,
                "booking_id": booking_id
            }
            
        except Exception as e:
            logger.error(f"Error processing booking reward: {e}")
            return {"success": False, "error": str(e)}

    def process_referral_completion(self, referrer_id: str, referred_user_id: str, 
                                   booking_id: str) -> Dict[str, Any]:
        """
        Process referral completion when referred user makes first booking
        """
        try:
            logger.info(f"Processing referral completion: {referrer_id} -> {referred_user_id}")
            
            # Find the referral record
            referrals = self.repository.get_user_referrals(referrer_id)
            target_referral = None
            
            for referral in referrals:
                if referral.referred_user_id == referred_user_id and referral.status == ModelStatusType.PENDING:
                    target_referral = referral
                    break
            
            if not target_referral:
                return {"success": False, "error": "Referral not found or already completed"}
            
            # Update referral status
            self.repository.update_referral_status(target_referral.referral_id, ModelStatusType.COMPLETED)
            
            # Give reward to referrer
            if target_referral.reward_points > 0:
                self.repository.update_user_points(
                    user_id=referrer_id,
                    points_to_add=target_referral.reward_points,
                    transaction_type="referral_bonus",
                    description=f"Referral bonus for {referred_user_id}",
                    booking_id=booking_id
                )
            
            # Update referrer's referral count
            loyalty = self.repository.get_user_loyalty(referrer_id)
            if loyalty:
                loyalty.referral_count += 1
                loyalty.updated_at = datetime.utcnow()
                self.db.commit()
            
            return {
                "success": True,
                "referral_id": target_referral.referral_id,
                "points_awarded": target_referral.reward_points
            }
            
        except Exception as e:
            logger.error(f"Error processing referral completion: {e}")
            return {"success": False, "error": str(e)}

    def claim_personalized_reward(self, user_id: str, reward_id: int) -> Dict[str, Any]:
        """
        Claim a personalized reward
        """
        try:
            logger.info(f"User {user_id} claiming personalized reward {reward_id}")
            
            success = self.repository.claim_personalized_reward(reward_id, user_id)
            
            if success:
                return {
                    "success": True,
                    "message": "Reward claimed successfully"
                }
            else:
                return {
                    "success": False,
                    "error": "Reward not found or already claimed"
                }
                
        except Exception as e:
            logger.error(f"Error claiming personalized reward: {e}")
            return {"success": False, "error": str(e)}

    def redeem_points(self, user_id: str, points_to_redeem: int, 
                     booking_id: str = None) -> Dict[str, Any]:
        """
        Redeem user points
        """
        try:
            logger.info(f"User {user_id} redeeming {points_to_redeem} points")
            
            success = self.repository.redeem_user_points(
                user_id=user_id,
                points_to_redeem=points_to_redeem,
                description="Points redemption",
                booking_id=booking_id
            )
            
            if success:
                return {
                    "success": True,
                    "points_redeemed": points_to_redeem,
                    "message": "Points redeemed successfully"
                }
            else:
                return {
                    "success": False,
                    "error": "Insufficient points or invalid request"
                }
                
        except Exception as e:
            logger.error(f"Error redeeming points: {e}")
            return {"success": False, "error": str(e)}

    # ==================== PRIVATE HELPER METHODS ====================
    
    def _get_user_loyalty_info(self, user_id: str) -> Optional[UserLoyaltyResponse]:
        """Get user loyalty information"""
        loyalty = self.repository.get_user_loyalty(user_id)
        if not loyalty:
            return None
        
        return UserLoyaltyResponse(
            id=loyalty.id,
            user_id=loyalty.user_id,
            loyalty_tier=loyalty.loyalty_tier,
            total_points_earned=loyalty.total_points_earned,
            total_points_redeemed=loyalty.total_points_redeemed,
            current_points_balance=loyalty.current_points_balance,
            points_to_next_tier=loyalty.points_to_next_tier,
            tier_upgraded_at=loyalty.tier_upgraded_at,
            total_bookings=loyalty.total_bookings,
            total_spent=float(loyalty.total_spent),
            last_booking_date=loyalty.last_booking_date,
            referral_count=loyalty.referral_count,
            created_at=loyalty.created_at,
            updated_at=loyalty.updated_at
        )

    def _determine_user_audience(self, user_id: str, user_loyalty: Optional[UserLoyaltyResponse]) -> str:
        """Determine user audience type based on loyalty and behavior"""
        if not user_loyalty:
            return "first_time_users"
        
        # Check loyalty tier
        if user_loyalty.loyalty_tier == "platinum":
            return "loyalty_platinum"
        elif user_loyalty.loyalty_tier == "gold":
            return "loyalty_gold"
        elif user_loyalty.loyalty_tier == "silver":
            return "loyalty_silver"
        
        # Check booking count
        if user_loyalty.total_bookings == 0:
            return "first_time_users"
        elif user_loyalty.total_bookings == 1:
            return "new_users"
        else:
            return "returning_users"

    def _get_ads_for_page(self, page: PageType, section: SectionType, audience: str) -> List[Dict[str, Any]]:
        """Get advertisements for specific page and section"""
        try:
            from dto.rewards_schema import AdFilter
            
            filter_data = AdFilter(
                page=page,
                section=section,
                audience=AudienceType.ALL,  # Start with ALL, then check specific audience
                is_active=True
            )
            
            ads, _ = self.repository.get_advertisements_by_filter(filter_data, page=1, size=10)
            
            # Convert to dictionary format
            ad_contents = []
            for ad in ads:
                # Check if ad is for specific audience or ALL
                if ad.audience == "all" or ad.audience == audience:
                    ad_contents.append({
                        "ad_id": ad.ad_id,
                        "title": ad.title,
                        "image_url": ad.image_url,
                        "redirect_url": ad.redirect_url,
                        "priority": ad.priority
                    })
            
            # Sort by priority
            ad_contents.sort(key=lambda x: x["priority"], reverse=True)
            return ad_contents[:5]  # Limit to top 5 ads
            
        except Exception as e:
            logger.error(f"Error getting ads: {e}")
            return []

    def _get_rewards_for_page(self, page: PageType, section: SectionType, audience: str) -> List[Dict[str, Any]]:
        """Get rewards for specific page and section"""
        try:
            from dto.rewards_schema import RewardFilter
            
            filter_data = RewardFilter(
                page=page,
                section=section,
                audience=AudienceType.ALL,
                is_active=True
            )
            
            rewards, _ = self.repository.get_rewards_by_filter(filter_data, page=1, size=10)
            
            # Convert to dictionary format
            reward_contents = []
            for reward in rewards:
                # Check if reward is for specific audience or ALL
                if reward.audience == "all" or reward.audience == audience:
                    reward_contents.append({
                        "reward_id": reward.reward_id,
                        "name": reward.name,
                        "description": reward.description,
                        "rule_json": reward.rule_json,
                        "priority": reward.priority
                    })
            
            # Sort by priority
            reward_contents.sort(key=lambda x: x["priority"], reverse=True)
            return reward_contents[:3]  # Limit to top 3 rewards
            
        except Exception as e:
            logger.error(f"Error getting rewards: {e}")
            return []

    def _get_offers_for_page(self, page: PageType, section: SectionType, 
                           audience: str, user_id: str) -> List[Dict[str, Any]]:
        """Get offers for specific page and section"""
        try:
            from dto.rewards_schema import OfferFilter
            
            filter_data = OfferFilter(
                page=page,
                section=section,
                audience=AudienceType.ALL,
                is_active=True
            )
            
            offers, _ = self.repository.get_offers_by_filter(filter_data, page=1, size=10)
            
            # Convert to dictionary format and check usage limits
            offer_contents = []
            for offer in offers:
                # Check if offer is for specific audience or ALL
                if offer.audience == "all" or offer.audience == audience:
                    # Check usage limits (assuming max_usage_per_user is in conditions_json)
                    max_usage = offer.conditions_json.get("maxUsagePerUser", 999)
                    usage_count = self.repository.get_user_offer_usage_count(user_id, offer.offer_id)
                    if usage_count < max_usage:
                        offer_contents.append({
                            "offer_id": offer.offer_id,
                            "title": offer.title,
                            "description": offer.description,
                            "discount_percentage": float(offer.discount_percentage),
                            "discount_amount": float(offer.discount_amount),
                            "conditions_json": offer.conditions_json,
                            "priority": offer.priority
                        })
            
            # Sort by priority
            offer_contents.sort(key=lambda x: x["priority"], reverse=True)
            return offer_contents[:5]  # Limit to top 5 offers
            
        except Exception as e:
            logger.error(f"Error getting offers: {e}")
            return []

    def _get_personalized_rewards(self, user_id: str) -> List[Dict[str, Any]]:
        """Get personalized rewards for user"""
        try:
            rewards = self.repository.get_user_personalized_rewards(user_id, unclaimed_only=True)
            
            # Convert to dictionary format
            reward_contents = []
            for reward in rewards:
                reward_contents.append({
                    "id": reward.id,
                    "user_id": reward.user_id,
                    "reward_id": reward.reward_id,
                    "custom_message": reward.custom_message,
                    "valid_from": reward.valid_from,
                    "valid_till": reward.valid_till,
                    "status": reward.status
                })
            
            return reward_contents[:3]  # Limit to top 3 personalized rewards
            
        except Exception as e:
            logger.error(f"Error getting personalized rewards: {e}")
            return []

    def _apply_context_filters(self, ads: List[Dict[str, Any]], rewards: List[Dict[str, Any]], 
                              offers: List[Dict[str, Any]], context: Dict[str, Any]):
        """Apply additional context filters to content"""
        # Filter offers based on service category
        if "service_category" in context:
            service_category = context["service_category"]
            offers[:] = [offer for offer in offers 
                        if offer["conditions_json"].get("service") == service_category or 
                        "service" not in offer["conditions_json"]]
        
        # Filter rewards based on minimum amount
        if "amount" in context:
            amount = context["amount"]
            rewards[:] = [reward for reward in rewards 
                         if reward["rule_json"].get("minAmount", 0) <= amount]

    def _check_and_process_tier_upgrade(self, user_id: str):
        """Check if user should be upgraded to next tier"""
        try:
            loyalty = self.repository.get_user_loyalty(user_id)
            if not loyalty:
                return
            
            # Get next tier
            next_tier = self.repository.get_next_tier(loyalty.current_points_balance)
            if not next_tier:
                return
            
            # Check if user qualifies for next tier
            if loyalty.current_points_balance >= next_tier.min_points:
                # Upgrade user
                self.repository.update_user_tier(user_id, next_tier.tier_name)
                
                # Create personalized reward for tier upgrade
                tier_upgrade_reward = {
                    "user_id": user_id,
                    "title": f"Congratulations! You've reached {next_tier.tier_name.title()} tier!",
                    "custom_message": f"Welcome to {next_tier.tier_name.title()} tier! 🎉",
                    "reward_type": "points",
                    "reward_value": 100,  # Bonus points for tier upgrade
                    "trigger_type": "tier_upgrade",
                    "valid_from": date.today(),
                    "valid_till": None
                }
                
                self.repository.create_personalized_reward(tier_upgrade_reward)
                logger.info(f"User {user_id} upgraded to {next_tier.tier_name} tier")
                
        except Exception as e:
            logger.error(f"Error checking tier upgrade: {e}")

    # ==================== ADMIN/MANAGEMENT METHODS ====================
    
    def create_reward_rule(self, rule_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new reward rule"""
        try:
            from models.rewards_models import RewardRules
            
            rule = RewardRules(**rule_data)
            self.db.add(rule)
            self.db.commit()
            self.db.refresh(rule)
            
            logger.info(f"Created reward rule: {rule.id}")
            return {"success": True, "rule_id": rule.id}
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating reward rule: {e}")
            return {"success": False, "error": str(e)}

    def get_reward_statistics(self) -> Dict[str, Any]:
        """Get reward system statistics"""
        return self.repository.get_reward_statistics()

    def get_user_reward_statistics(self, user_id: str) -> Dict[str, Any]:
        """Get user-specific reward statistics"""
        return self.repository.get_user_reward_statistics(user_id)
