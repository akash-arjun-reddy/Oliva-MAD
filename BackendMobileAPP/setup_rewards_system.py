#!/usr/bin/env python3
"""
Setup script for the Rewards & Engagement Ecosystem
This script initializes the system with default data and configurations.
"""

import os
import sys
import json
from datetime import datetime, date
from sqlalchemy.orm import Session

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database.connection import SessionLocal, engine
from models.rewards_models import (
    RewardsPoints, Referrals, LoyaltyTiers, JoiningBonus, PrizesGifts,
    OffersDiscounts, Advertisements, PersonalizedRewards, UserLoyalty,
    RewardTransactions, OfferUsage, UserRewardClaims, RewardRules,
    LoyaltyTierBenefits
)
from repository.rewards_repository import RewardsRepository


def create_default_loyalty_tiers(db: Session):
    """Create default loyalty tiers"""
    print("Creating default loyalty tiers...")
    
    default_tiers = [
        {
            "tier_name": "bronze",
            "min_points": 0,
            "benefits_json": {
                "discount": 0,
                "priority_booking": False,
                "description": "Basic tier - start earning points!"
            },
            "priority": 1,
            "status": "active"
        },
        {
            "tier_name": "silver",
            "min_points": 500,
            "benefits_json": {
                "discount": 5,
                "priority_booking": True,
                "description": "Silver benefits - 5% discount and priority booking"
            },
            "priority": 2,
            "status": "active"
        },
        {
            "tier_name": "gold",
            "min_points": 1000,
            "benefits_json": {
                "discount": 10,
                "priority_booking": True,
                "free_service": "skin_check",
                "description": "Gold benefits - 10% discount, priority booking, and free skin check"
            },
            "priority": 3,
            "status": "active"
        },
        {
            "tier_name": "platinum",
            "min_points": 2500,
            "benefits_json": {
                "discount": 15,
                "priority_booking": True,
                "free_service": "consultation",
                "description": "Platinum benefits - 15% discount, priority booking, and free consultation"
            },
            "priority": 4,
            "status": "active"
        },
        {
            "tier_name": "diamond",
            "min_points": 5000,
            "benefits_json": {
                "discount": 20,
                "priority_booking": True,
                "free_service": "premium_treatment",
                "description": "Diamond benefits - 20% discount, priority booking, and free premium treatment"
            },
            "priority": 5,
            "status": "active"
        }
    ]
    
    for tier_data in default_tiers:
        tier = LoyaltyTiers(**tier_data)
        db.add(tier)
    
    db.commit()
    print(f"✅ Created {len(default_tiers)} loyalty tiers")


def create_default_reward_rules(db: Session):
    """Create default reward rules"""
    print("Creating default reward rules...")
    
    default_rules = [
        {
            "name": "Booking Points",
            "description": "Earn points on every booking",
            "rule_json": {
                "perSpend": 10,
                "minAmount": 500,
                "type": "points"
            },
            "page": "booking",
            "section": "summary",
            "audience": "all",
            "priority": 1,
            "status": "active",
            "valid_from": date.today()
        },
        {
            "name": "First Booking Bonus",
            "description": "Get bonus points on your first booking",
            "rule_json": {
                "flatPoints": 100,
                "minAmount": 0,
                "type": "points"
            },
            "page": "booking",
            "section": "summary",
            "audience": "first_time_users",
            "priority": 2,
            "status": "active",
            "valid_from": date.today()
        },
        {
            "name": "High Value Booking",
            "description": "Extra points for high-value bookings",
            "rule_json": {
                "perSpend": 15,
                "minAmount": 2000,
                "type": "points"
            },
            "page": "booking",
            "section": "summary",
            "audience": "all",
            "priority": 3,
            "status": "active",
            "valid_from": date.today()
        }
    ]
    
    for rule_data in default_rules:
        rule = RewardsPoints(**rule_data)
        db.add(rule)
    
    db.commit()
    print(f"✅ Created {len(default_rules)} reward rules")


def create_default_offers(db: Session):
    """Create default offers"""
    print("Creating default offers...")
    
    default_offers = [
        {
            "title": "Welcome Offer",
            "description": "20% off on your first booking",
            "page": "home",
            "section": "banner",
            "audience": "first_time_users",
            "conditions_json": {
                "service": "any",
                "minAmount": 500,
                "maxUsage": 1
            },
            "discount_percentage": 20.0,
            "discount_amount": 0.0,

            "priority": 1,
            "status": "active",
            "valid_from": date.today()
        },
        {
            "title": "Hair Care Special",
            "description": "15% off on all hair services",
            "page": "booking",
            "section": "sidebar",
            "audience": "all",
            "conditions_json": {
                "service": "hair",
                "minAmount": 300
            },
            "discount_percentage": 15.0,
            "discount_amount": 0.0,

            "priority": 2,
            "status": "active",
            "valid_from": date.today()
        },
        {
            "title": "Skin Care Bundle",
            "description": "25% off on skin care packages",
            "page": "shop",
            "section": "banner",
            "audience": "loyalty_silver",
            "conditions_json": {
                "service": "skin",
                "minAmount": 1000
            },
            "discount_percentage": 25.0,
            "discount_amount": 0.0,

            "priority": 3,
            "status": "active",
            "valid_from": date.today()
        }
    ]
    
    for offer_data in default_offers:
        offer = OffersDiscounts(**offer_data)
        db.add(offer)
    
    db.commit()
    print(f"✅ Created {len(default_offers)} default offers")


def create_sample_advertisements(db: Session):
    """Create sample advertisements"""
    print("Creating sample advertisements...")
    
    sample_ads = [
        {
            "title": "Summer Special",
            "image_url": "https://example.com/summer-ad.jpg",
            "redirect_url": "/offers/summer",
            "page": "home",
            "section": "banner",
            "audience": "all",
            "priority": 1,
            "status": "active",
            "valid_from": date.today()
        },
        {
            "title": "VIP Member Exclusive",
            "image_url": "https://example.com/vip-ad.jpg",
            "redirect_url": "/vip-benefits",
            "page": "profile",
            "section": "popup",
            "audience": "loyalty_gold",
            "priority": 2,
            "status": "active",
            "valid_from": date.today()
        },
        {
            "title": "New User Welcome",
            "image_url": "https://example.com/welcome-ad.jpg",
            "redirect_url": "/welcome-bonus",
            "page": "dashboard",
            "section": "card",
            "audience": "first_time_users",
            "priority": 3,
            "status": "active",
            "valid_from": date.today()
        }
    ]
    
    for ad_data in sample_ads:
        ad = Advertisements(**ad_data)
        db.add(ad)
    
    db.commit()
    print(f"✅ Created {len(sample_ads)} sample advertisements")


def create_sample_personalized_rewards(db: Session):
    """Create sample personalized rewards"""
    print("Creating sample personalized rewards...")
    
    sample_rewards = [
        {
            "user_id": "sample_user_1",

            "custom_message": "Happy Birthday! Here's 100 bonus points just for you!",
            "reward_type": "points",
            "reward_value": 100,
            "trigger_type": "birthday",
            "status": "active",
            "valid_from": date.today()
        },
        {
            "user_id": "sample_user_2",

            "custom_message": "Congratulations on your 10th visit! Enjoy a free consultation!",
            "reward_type": "free_service",
            "reward_value": 500,  # Value of consultation
            "trigger_type": "milestone",
            "status": "active",
            "valid_from": date.today()
        }
    ]
    
    for reward_data in sample_rewards:
        reward = PersonalizedRewards(**reward_data)
        db.add(reward)
    
    db.commit()
    print(f"✅ Created {len(sample_rewards)} sample personalized rewards")


def create_sample_user_loyalty(db: Session):
    """Create sample user loyalty records"""
    print("Creating sample user loyalty records...")
    
    sample_users = [
        {
            "user_id": "sample_user_1",
            "loyalty_tier": "silver",
            "total_points_earned": 750,
            "total_points_redeemed": 250,
            "current_points_balance": 500,
            "total_bookings": 3,
            "total_spent": 1500.0,
            "referral_count": 1
        },
        {
            "user_id": "sample_user_2",
            "loyalty_tier": "gold",
            "total_points_earned": 1500,
            "total_points_redeemed": 500,
            "current_points_balance": 1000,
            "total_bookings": 8,
            "total_spent": 4000.0,
            "referral_count": 3
        },
        {
            "user_id": "sample_user_3",
            "loyalty_tier": "bronze",
            "total_points_earned": 200,
            "total_points_redeemed": 0,
            "current_points_balance": 200,
            "total_bookings": 1,
            "total_spent": 500.0,
            "referral_count": 0
        }
    ]
    
    for user_data in sample_users:
        loyalty = UserLoyalty(**user_data)
        db.add(loyalty)
    
    db.commit()
    print(f"✅ Created {len(sample_users)} sample user loyalty records")


def create_reward_rules(db: Session):
    """Create reward rules for the rules engine"""
    print("Creating reward rules for rules engine...")
    
    rules = [
        {
            "rule_name": "Booking Reward Rule",
            "rule_type": "booking",
            "conditions_json": {
                "minAmount": 500,
                "serviceCategory": "any"
            },
            "reward_json": {
                "points": 10,
                "type": "points"
            },
            "priority": 1,
            "is_active": True
        },
        {
            "rule_name": "High Value Booking Rule",
            "rule_type": "booking",
            "conditions_json": {
                "minAmount": 2000,
                "serviceCategory": "any"
            },
            "reward_json": {
                "points": 25,
                "type": "points"
            },
            "priority": 2,
            "is_active": True
        },
        {
            "rule_name": "Hair Service Bonus",
            "rule_type": "booking",
            "conditions_json": {
                "minAmount": 300,
                "serviceCategory": "hair"
            },
            "reward_json": {
                "points": 5,
                "type": "bonus_points"
            },
            "priority": 3,
            "is_active": True
        }
    ]
    
    for rule_data in rules:
        rule = RewardRules(**rule_data)
        db.add(rule)
    
    db.commit()
    print(f"✅ Created {len(rules)} reward rules")


def create_loyalty_tier_benefits(db: Session):
    """Create loyalty tier benefits"""
    print("Creating loyalty tier benefits...")
    
    benefits = [
        {
            "tier_name": "silver",
            "benefit_type": "discount",
            "benefit_value": "5",
            "description": "5% discount on all services"
        },
        {
            "tier_name": "silver",
            "benefit_type": "priority",
            "benefit_value": "true",
            "description": "Priority booking"
        },
        {
            "tier_name": "gold",
            "benefit_type": "discount",
            "benefit_value": "10",
            "description": "10% discount on all services"
        },
        {
            "tier_name": "gold",
            "benefit_type": "priority",
            "benefit_value": "true",
            "description": "Priority booking"
        },
        {
            "tier_name": "gold",
            "benefit_type": "free_service",
            "benefit_value": "skin_check",
            "description": "Free skin check consultation"
        },
        {
            "tier_name": "platinum",
            "benefit_type": "discount",
            "benefit_value": "15",
            "description": "15% discount on all services"
        },
        {
            "tier_name": "platinum",
            "benefit_type": "free_service",
            "benefit_value": "consultation",
            "description": "Free consultation"
        }
    ]
    
    for benefit_data in benefits:
        benefit = LoyaltyTierBenefits(**benefit_data)
        db.add(benefit)
    
    db.commit()
    print(f"✅ Created {len(benefits)} loyalty tier benefits")


def main():
    """Main setup function"""
    print("🚀 Setting up Rewards & Engagement Ecosystem...")
    print("=" * 50)
    
    # Create database session
    db = SessionLocal()
    
    try:
        # Create all default data
        create_default_loyalty_tiers(db)
        create_default_reward_rules(db)
        create_default_offers(db)
        create_sample_advertisements(db)
        create_sample_personalized_rewards(db)
        create_sample_user_loyalty(db)
        create_reward_rules(db)
        create_loyalty_tier_benefits(db)
        
        print("\n" + "=" * 50)
        print("✅ Rewards & Engagement Ecosystem setup completed successfully!")
        print("\n📋 Summary:")
        print("- Loyalty tiers: Bronze, Silver, Gold, Platinum, Diamond")
        print("- Default reward rules: Booking points, First booking bonus, High value bonus")
        print("- Sample offers: Welcome offer, Hair care special, Skin care bundle")
        print("- Sample advertisements: Summer special, VIP exclusive, New user welcome")
        print("- Sample personalized rewards: Birthday gifts, Milestone rewards")
        print("- Sample user loyalty records for testing")
        print("- Reward rules engine configured")
        print("- Loyalty tier benefits defined")
        
        print("\n🔗 Next Steps:")
        print("1. Start your FastAPI server: python main.py")
        print("2. Visit http://localhost:8000/docs for API documentation")
        print("3. Test the endpoints using the provided examples")
        print("4. Integrate with your mobile app using the UI content endpoints")
        
    except Exception as e:
        print(f"❌ Error during setup: {e}")
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()
