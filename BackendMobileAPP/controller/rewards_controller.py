from fastapi import APIRouter, Depends, HTTPException, Query, Path, Body
from sqlalchemy.orm import Session
from typing import Optional, List
from datetime import datetime

from database.session import get_db
from models.user import User
from security.jwt import get_current_user
from service.rewards_engine_service import RewardsEngineService
from dto.rewards_schema import (
    UIContentRequest, UIContentResponse, BaseResponse, PaginatedResponse,
    AdvertisementCreate, AdvertisementUpdate, AdvertisementResponse,
    RewardsPointsCreate as RewardCreate, RewardsPointsUpdate as RewardUpdate, RewardsPointsResponse as RewardResponse,
    OfferDiscountCreate as OfferCreate, OfferDiscountUpdate as OfferUpdate, OfferDiscountResponse as OfferResponse,
    PersonalizedRewardCreate, PersonalizedRewardUpdate, PersonalizedRewardResponse,
    UserLoyaltyResponse, RewardTransactionResponse,
    ReferralCreate, ReferralResponse,
    RewardFilter, OfferFilter, AdFilter,
    RewardStats, OfferStats, UserRewardStats,
    PageType, SectionType, AudienceType
)
from utils.logger import get_logger

router = APIRouter(prefix="/api/rewards", tags=["Rewards & Engagement"])
logger = get_logger()


# ==================== UI CONTENT ENDPOINTS ====================

@router.post("/ui-content", response_model=UIContentResponse)
async def get_ui_content(
    request: UIContentRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get dynamic UI content for mobile app
    This is the main endpoint that the mobile app calls to get ads, rewards, offers, etc.
    """
    try:
        rewards_service = RewardsEngineService(db)
        return rewards_service.get_ui_content(request)
    except Exception as e:
        logger.error(f"Error getting UI content: {e}")
        raise HTTPException(status_code=500, detail="Failed to get UI content")


@router.get("/ui-content/{page}/{section}")
async def get_ui_content_simple(
    page: PageType = Path(...),
    section: SectionType = Path(...),
    user_id: str = Query(...),
    additional_context: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """
    Simplified UI content endpoint for mobile app
    """
    try:
        import json
        context = json.loads(additional_context) if additional_context else None
        
        request = UIContentRequest(
            page=page,
            section=section,
            user_id=user_id,
            additional_context=context
        )
        
        rewards_service = RewardsEngineService(db)
        return rewards_service.get_ui_content(request)
    except Exception as e:
        logger.error(f"Error getting UI content: {e}")
        raise HTTPException(status_code=500, detail="Failed to get UI content")


# ==================== REWARD PROCESSING ENDPOINTS ====================

@router.post("/process-booking-reward")
async def process_booking_reward(
    user_id: str = Query(...),
    booking_amount: float = Query(...),
    booking_id: str = Query(...),
    service_category: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Process rewards when a booking is completed
    """
    try:
        rewards_service = RewardsEngineService(db)
        result = rewards_service.process_booking_reward(
            user_id=user_id,
            booking_amount=booking_amount,
            booking_id=booking_id,
            service_category=service_category
        )
        return result
    except Exception as e:
        logger.error(f"Error processing booking reward: {e}")
        raise HTTPException(status_code=500, detail="Failed to process booking reward")


@router.post("/process-referral-completion")
async def process_referral_completion(
    referrer_id: str = Query(...),
    referred_user_id: str = Query(...),
    booking_id: str = Query(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Process referral completion when referred user makes first booking
    """
    try:
        rewards_service = RewardsEngineService(db)
        result = rewards_service.process_referral_completion(
            referrer_id=referrer_id,
            referred_user_id=referred_user_id,
            booking_id=booking_id
        )
        return result
    except Exception as e:
        logger.error(f"Error processing referral completion: {e}")
        raise HTTPException(status_code=500, detail="Failed to process referral completion")


@router.post("/claim-personalized-reward/{reward_id}")
async def claim_personalized_reward(
    reward_id: int = Path(...),
    user_id: str = Query(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Claim a personalized reward
    """
    try:
        rewards_service = RewardsEngineService(db)
        result = rewards_service.claim_personalized_reward(user_id, reward_id)
        return result
    except Exception as e:
        logger.error(f"Error claiming personalized reward: {e}")
        raise HTTPException(status_code=500, detail="Failed to claim personalized reward")


@router.post("/redeem-points")
async def redeem_points(
    user_id: str = Query(...),
    points_to_redeem: int = Query(...),
    booking_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Redeem user points
    """
    try:
        rewards_service = RewardsEngineService(db)
        result = rewards_service.redeem_points(
            user_id=user_id,
            points_to_redeem=points_to_redeem,
            booking_id=booking_id
        )
        return result
    except Exception as e:
        logger.error(f"Error redeeming points: {e}")
        raise HTTPException(status_code=500, detail="Failed to redeem points")


# ==================== USER LOYALTY ENDPOINTS ====================

@router.get("/user-loyalty/{user_id}", response_model=UserLoyaltyResponse)
async def get_user_loyalty(
    user_id: str = Path(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get user loyalty information
    """
    try:
        rewards_service = RewardsEngineService(db)
        loyalty = rewards_service._get_user_loyalty_info(user_id)
        if not loyalty:
            raise HTTPException(status_code=404, detail="User loyalty not found")
        return loyalty
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting user loyalty: {e}")
        raise HTTPException(status_code=500, detail="Failed to get user loyalty")


@router.get("/user-statistics/{user_id}", response_model=UserRewardStats)
async def get_user_reward_statistics(
    user_id: str = Path(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get user reward statistics
    """
    try:
        rewards_service = RewardsEngineService(db)
        stats = rewards_service.get_user_reward_statistics(user_id)
        if not stats:
            raise HTTPException(status_code=404, detail="User statistics not found")
        return stats
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting user statistics: {e}")
        raise HTTPException(status_code=500, detail="Failed to get user statistics")


# ==================== ADVERTISEMENT ENDPOINTS ====================

@router.post("/advertisements", response_model=AdvertisementResponse)
async def create_advertisement(
    ad_data: AdvertisementCreate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Create a new advertisement
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        ad_dict = ad_data.model_dump()
        ad_dict["created_by"] = current_user.id
        ad_dict["valid_from"] = datetime.utcnow().date()
        
        ad = repo.create_advertisement(ad_dict)
        return AdvertisementResponse.model_validate(ad)
    except Exception as e:
        logger.error(f"Error creating advertisement: {e}")
        raise HTTPException(status_code=500, detail="Failed to create advertisement")


@router.get("/advertisements", response_model=PaginatedResponse)
async def get_advertisements(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    page_type: Optional[PageType] = Query(None),
    section_type: Optional[SectionType] = Query(None),
    audience_type: Optional[AudienceType] = Query(None),
    is_active: Optional[bool] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get advertisements with filtering and pagination
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        filter_data = AdFilter(
            page=page_type,
            section=section_type,
            audience=audience_type,
            is_active=is_active
        )
        
        ads, total = repo.get_advertisements_by_filter(filter_data, page, size)
        
        total_pages = (total + size - 1) // size
        
        return PaginatedResponse(
            data=[AdvertisementResponse.model_validate(ad) for ad in ads],
            pagination={
                "page": page,
                "size": size,
                "total": total,
                "total_pages": total_pages
            }
        )
    except Exception as e:
        logger.error(f"Error getting advertisements: {e}")
        raise HTTPException(status_code=500, detail="Failed to get advertisements")


@router.put("/advertisements/{ad_id}", response_model=AdvertisementResponse)
async def update_advertisement(
    ad_id: int = Path(...),
    ad_data: AdvertisementUpdate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update an advertisement
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        update_dict = ad_data.model_dump(exclude_unset=True)
        update_dict["updated_by"] = current_user.id
        
        ad = repo.update_advertisement(ad_id, update_dict)
        if not ad:
            raise HTTPException(status_code=404, detail="Advertisement not found")
        
        return AdvertisementResponse.model_validate(ad)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating advertisement: {e}")
        raise HTTPException(status_code=500, detail="Failed to update advertisement")


@router.post("/advertisements/{ad_id}/increment-views")
async def increment_ad_views(
    ad_id: int = Path(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Increment advertisement view count
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        success = repo.increment_ad_views(ad_id)
        if not success:
            raise HTTPException(status_code=404, detail="Advertisement not found")
        
        return {"success": True, "message": "View count incremented"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error incrementing ad views: {e}")
        raise HTTPException(status_code=500, detail="Failed to increment ad views")


@router.post("/advertisements/{ad_id}/increment-clicks")
async def increment_ad_clicks(
    ad_id: int = Path(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Increment advertisement click count
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        success = repo.increment_ad_clicks(ad_id)
        if not success:
            raise HTTPException(status_code=404, detail="Advertisement not found")
        
        return {"success": True, "message": "Click count incremented"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error incrementing ad clicks: {e}")
        raise HTTPException(status_code=500, detail="Failed to increment ad clicks")


# ==================== REWARDS ENDPOINTS ====================

@router.post("/rewards", response_model=RewardResponse)
async def create_reward(
    reward_data: RewardCreate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Create a new reward
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        reward_dict = reward_data.model_dump()
        reward_dict["created_by"] = current_user.id
        reward_dict["valid_from"] = datetime.utcnow().date()
        
        reward = repo.create_reward(reward_dict)
        return RewardResponse.model_validate(reward)
    except Exception as e:
        logger.error(f"Error creating reward: {e}")
        raise HTTPException(status_code=500, detail="Failed to create reward")


@router.get("/rewards", response_model=PaginatedResponse)
async def get_rewards(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    page_type: Optional[PageType] = Query(None),
    section_type: Optional[SectionType] = Query(None),
    audience_type: Optional[AudienceType] = Query(None),
    is_active: Optional[bool] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get rewards with filtering and pagination
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        filter_data = RewardFilter(
            page=page_type,
            section=section_type,
            audience=audience_type,
            is_active=is_active
        )
        
        rewards, total = repo.get_rewards_by_filter(filter_data, page, size)
        
        total_pages = (total + size - 1) // size
        
        return PaginatedResponse(
            data=[RewardResponse.model_validate(reward) for reward in rewards],
            pagination={
                "page": page,
                "size": size,
                "total": total,
                "total_pages": total_pages
            }
        )
    except Exception as e:
        logger.error(f"Error getting rewards: {e}")
        raise HTTPException(status_code=500, detail="Failed to get rewards")


@router.put("/rewards/{reward_id}", response_model=RewardResponse)
async def update_reward(
    reward_id: int = Path(...),
    reward_data: RewardUpdate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update a reward
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        update_dict = reward_data.model_dump(exclude_unset=True)
        update_dict["updated_by"] = current_user.id
        
        reward = repo.update_reward(reward_id, update_dict)
        if not reward:
            raise HTTPException(status_code=404, detail="Reward not found")
        
        return RewardResponse.model_validate(reward)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating reward: {e}")
        raise HTTPException(status_code=500, detail="Failed to update reward")


# ==================== OFFERS ENDPOINTS ====================

@router.post("/offers", response_model=OfferResponse)
async def create_offer(
    offer_data: OfferCreate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Create a new offer
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        offer_dict = offer_data.model_dump()
        offer_dict["created_by"] = current_user.id
        offer_dict["valid_from"] = datetime.utcnow().date()
        
        offer = repo.create_offer(offer_dict)
        return OfferResponse.model_validate(offer)
    except Exception as e:
        logger.error(f"Error creating offer: {e}")
        raise HTTPException(status_code=500, detail="Failed to create offer")


@router.get("/offers", response_model=PaginatedResponse)
async def get_offers(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    page_type: Optional[PageType] = Query(None),
    section_type: Optional[SectionType] = Query(None),
    audience_type: Optional[AudienceType] = Query(None),
    service_category: Optional[str] = Query(None),
    is_active: Optional[bool] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get offers with filtering and pagination
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        filter_data = OfferFilter(
            page=page_type,
            section=section_type,
            audience=audience_type,
            service_category=service_category,
            is_active=is_active
        )
        
        offers, total = repo.get_offers_by_filter(filter_data, page, size)
        
        total_pages = (total + size - 1) // size
        
        return PaginatedResponse(
            data=[OfferResponse.model_validate(offer) for offer in offers],
            pagination={
                "page": page,
                "size": size,
                "total": total,
                "total_pages": total_pages
            }
        )
    except Exception as e:
        logger.error(f"Error getting offers: {e}")
        raise HTTPException(status_code=500, detail="Failed to get offers")


@router.put("/offers/{offer_id}", response_model=OfferResponse)
async def update_offer(
    offer_id: int = Path(...),
    offer_data: OfferUpdate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update an offer
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        update_dict = offer_data.model_dump(exclude_unset=True)
        update_dict["updated_by"] = current_user.id
        
        offer = repo.update_offer(offer_id, update_dict)
        if not offer:
            raise HTTPException(status_code=404, detail="Offer not found")
        
        return OfferResponse.model_validate(offer)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating offer: {e}")
        raise HTTPException(status_code=500, detail="Failed to update offer")


# ==================== PERSONALIZED REWARDS ENDPOINTS ====================

@router.post("/personalized-rewards", response_model=PersonalizedRewardResponse)
async def create_personalized_reward(
    reward_data: PersonalizedRewardCreate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Create a personalized reward
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        reward_dict = reward_data.model_dump()
        reward_dict["created_by"] = current_user.id
        reward_dict["valid_from"] = datetime.utcnow().date()
        
        reward = repo.create_personalized_reward(reward_dict)
        return PersonalizedRewardResponse.model_validate(reward)
    except Exception as e:
        logger.error(f"Error creating personalized reward: {e}")
        raise HTTPException(status_code=500, detail="Failed to create personalized reward")


@router.get("/personalized-rewards/{user_id}", response_model=List[PersonalizedRewardResponse])
async def get_user_personalized_rewards(
    user_id: str = Path(...),
    unclaimed_only: bool = Query(True),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get personalized rewards for a user
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        rewards = repo.get_user_personalized_rewards(user_id, unclaimed_only)
        return [PersonalizedRewardResponse.model_validate(reward) for reward in rewards]
    except Exception as e:
        logger.error(f"Error getting personalized rewards: {e}")
        raise HTTPException(status_code=500, detail="Failed to get personalized rewards")


# ==================== REFERRAL ENDPOINTS ====================

@router.post("/referrals", response_model=ReferralResponse)
async def create_referral(
    referral_data: ReferralCreate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Create a new referral
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        referral = repo.create_referral(
            referrer_id=referral_data.user_id,
            referred_user_id=referral_data.referred_user_id,
            reward_points=referral_data.reward_points,
            discount_amount=referral_data.discount_amount
        )
        return ReferralResponse.model_validate(referral)
    except Exception as e:
        logger.error(f"Error creating referral: {e}")
        raise HTTPException(status_code=500, detail="Failed to create referral")


@router.get("/referrals/{user_id}", response_model=List[ReferralResponse])
async def get_user_referrals(
    user_id: str = Path(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all referrals for a user
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        referrals = repo.get_user_referrals(user_id)
        return [ReferralResponse.model_validate(referral) for referral in referrals]
    except Exception as e:
        logger.error(f"Error getting user referrals: {e}")
        raise HTTPException(status_code=500, detail="Failed to get user referrals")


# ==================== STATISTICS ENDPOINTS ====================

@router.get("/statistics/rewards", response_model=RewardStats)
async def get_reward_statistics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get reward system statistics
    """
    try:
        rewards_service = RewardsEngineService(db)
        stats = rewards_service.get_reward_statistics()
        return RewardStats(**stats)
    except Exception as e:
        logger.error(f"Error getting reward statistics: {e}")
        raise HTTPException(status_code=500, detail="Failed to get reward statistics")


@router.get("/statistics/offers", response_model=OfferStats)
async def get_offer_statistics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get offer statistics
    """
    try:
        from repository.rewards_repository import RewardsRepository
        repo = RewardsRepository(db)
        
        # This would need to be implemented in the repository
        # For now, returning placeholder data
        return OfferStats(
            total_offers=0,
            active_offers=0,
            total_usage=0,
            total_discount_value=0.0
        )
    except Exception as e:
        logger.error(f"Error getting offer statistics: {e}")
        raise HTTPException(status_code=500, detail="Failed to get offer statistics")
