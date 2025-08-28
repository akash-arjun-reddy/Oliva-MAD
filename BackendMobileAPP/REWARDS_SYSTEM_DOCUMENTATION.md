# 🏆 Rewards & Engagement Ecosystem Documentation

## 📋 Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Database Schema](#database-schema)
4. [API Endpoints](#api-endpoints)
5. [Usage Examples](#usage-examples)
6. [Implementation Guide](#implementation-guide)
7. [Mobile App Integration](#mobile-app-integration)
8. [Admin Management](#admin-management)
9. [Testing](#testing)

## 🎯 Overview

The Rewards & Engagement Ecosystem is a comprehensive system that provides dynamic, rule-driven, and personalized rewards for your mobile app. Instead of hardcoding offers or rewards, everything lives in the database with rules, making the system flexible and scalable.

### Key Features
- **Dynamic Content Delivery**: Ads, rewards, offers delivered based on user context
- **Rule-Based Rewards**: Configurable rules for points, discounts, and gifts
- **Personalized Rewards**: User-specific rewards and gestures
- **Loyalty Tiers**: Bronze, Silver, Gold, Platinum, Diamond tiers
- **Referral System**: Complete referral tracking and rewards
- **Analytics**: Comprehensive tracking and statistics

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Mobile App    │    │   FastAPI       │    │   Database      │
│                 │    │   Backend       │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ UI Content  │◄┼────┼►│ Rewards     │ │    │ │ Rewards     │ │
│ │ Request     │ │    │ │ Engine      │ │    │ │ Tables      │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ ┌─────────────┐ │    │ │ Repository  │ │    │ │ User        │ │
│ │ Reward      │◄┼────┼►│ Layer       │ │    │ │ Loyalty     │ │
│ │ Actions     │ │    │ └─────────────┘ │    │ │ Tables      │ │
│ └─────────────┘ │    │                 │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🗄️ Database Schema

### Core Tables

#### 1. Rewards Points (`rewards_points`)
```sql
CREATE TABLE rewards_points (
    reward_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    description TEXT,
    rule_json JSON,  -- {"perSpend": 10, "minAmount": 500}
    page VARCHAR(50),
    section VARCHAR(50),
    audience VARCHAR(100),
    valid_from DATE,
    valid_till DATE,
    priority INT,
    status ENUM('active','inactive'),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW() ON UPDATE NOW()
);
```

#### 2. Offers & Discounts (`offers_discounts`)
```sql
CREATE TABLE offers_discounts (
    offer_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    description TEXT,
    page VARCHAR(50),
    section VARCHAR(50),
    audience VARCHAR(100),
    conditions_json JSON,  -- {"service": "hair", "minAmount": 500}
    discount_percentage DECIMAL(5,2),
    discount_amount DECIMAL(10,2),
    valid_from DATE,
    valid_till DATE,
    priority INT,
    status ENUM('active','inactive'),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW() ON UPDATE NOW()
);
```

#### 3. Advertisements (`ads`)
```sql
CREATE TABLE ads (
    ad_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    image_url VARCHAR(255),
    redirect_url VARCHAR(255),
    page VARCHAR(50),
    section VARCHAR(50),
    audience VARCHAR(100),
    valid_from DATE,
    valid_till DATE,
    priority INT,
    center_id VARCHAR(50),
    status ENUM('active','inactive'),
    click_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW() ON UPDATE NOW()
);
```

#### 4. User Loyalty (`user_loyalty`)
```sql
CREATE TABLE user_loyalty (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(50) UNIQUE,
    loyalty_tier VARCHAR(50) DEFAULT 'bronze',
    total_points_earned INT DEFAULT 0,
    total_points_redeemed INT DEFAULT 0,
    current_points_balance INT DEFAULT 0,
    points_to_next_tier INT DEFAULT 0,
    tier_upgraded_at TIMESTAMP NULL,
    total_bookings INT DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0.0,
    last_booking_date TIMESTAMP NULL,
    referral_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW() ON UPDATE NOW()
);
```

## 🔌 API Endpoints

### 1. UI Content Endpoints

#### Get Dynamic UI Content
```http
POST /api/rewards/ui-content
Content-Type: application/json

{
    "page": "home",
    "section": "banner",
    "user_id": "123",
    "additional_context": {
        "service_category": "hair",
        "amount": 1000
    }
}
```

**Response:**
```json
{
    "ads": [
        {
            "id": 1,
            "title": "Hair Care Special",
            "image_url": "https://example.com/hair-ad.jpg",
            "redirect_url": "/offers/hair",
            "priority": 1
        }
    ],
    "rewards": [
        {
            "id": 1,
            "name": "Booking Reward",
            "description": "Earn points on every booking",
            "reward_type": "points",
            "points_value": 10,
            "rule_config": {"perSpend": 10, "minAmount": 500}
        }
    ],
    "offers": [
        {
            "id": 1,
            "title": "20% Hair Care",
            "description": "Get 20% off on hair services",
            "offer_type": "percentage_discount",
            "discount_percentage": 20.0,
            "minimum_amount": 500.0,
            "conditions": {"service": "hair"}
        }
    ],
    "personalized_rewards": [
        {
            "id": 1,
            "title": "Birthday Gift 🎁",
            "message": "Happy Birthday! Here's your special gift",
            "reward_type": "points",
            "points_value": 100,
            "trigger_type": "birthday"
        }
    ],
    "user_loyalty": {
        "user_id": "123",
        "loyalty_tier": "silver",
        "current_points": 250,
        "total_earned": 500,
        "total_redeemed": 250,
        "total_bookings": 5,
        "total_spent": 2500.0
    }
}
```

#### Simplified UI Content (GET)
```http
GET /api/rewards/ui-content/home/banner?user_id=123&additional_context={"service_category":"hair"}
```

### 2. Reward Processing Endpoints

#### Process Booking Reward
```http
POST /api/rewards/process-booking-reward?user_id=123&booking_amount=1000&booking_id=BOOK001&service_category=hair
```

#### Claim Personalized Reward
```http
POST /api/rewards/claim-personalized-reward/1?user_id=123
```

#### Redeem Points
```http
POST /api/rewards/redeem-points?user_id=123&points_to_redeem=50&booking_id=BOOK001
```

### 3. User Loyalty Endpoints

#### Get User Loyalty
```http
GET /api/rewards/user-loyalty/123
```

#### Get User Statistics
```http
GET /api/rewards/user-statistics/123
```

### 4. Management Endpoints

#### Create Advertisement
```http
POST /api/rewards/advertisements
Content-Type: application/json

{
    "title": "Summer Special",
    "image_url": "https://example.com/summer-ad.jpg",
    "redirect_url": "/offers/summer",
    "page": "home",
    "section": "banner",
    "audience": "all",
    "priority": 1,
    "valid_till": "2024-08-31"
}
```

#### Create Reward
```http
POST /api/rewards/rewards
Content-Type: application/json

{
    "name": "First Booking Bonus",
    "description": "Get bonus points on your first booking",
    "rule_config": {
        "perSpend": 10,
        "minAmount": 500,
        "type": "points"
    },
    "page": "booking",
    "section": "summary",
    "audience": "first_time_users",
    "priority": 1
}
```

#### Create Offer
```http
POST /api/rewards/offers
Content-Type: application/json

{
    "title": "Hair Care Discount",
    "description": "20% off on all hair services",
    "page": "booking",
    "section": "sidebar",
    "audience": "all",
    "conditions": {
        "service": "hair",
        "minAmount": 500
    },
    "discount_percentage": 20.0,
    "minimum_amount": 500.0,
    "max_usage_per_user": 1
}
```

## 📱 Mobile App Integration

### 1. Basic Integration Flow

```dart
// Flutter/Dart example
class RewardsService {
  static Future<UIContentResponse> getUIContent({
    required String page,
    required String section,
    required String userId,
    Map<String, dynamic>? context,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/rewards/ui-content'),
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'page': page,
        'section': section,
        'user_id': userId,
        'additional_context': context,
      }),
    );
    
    return UIContentResponse.fromJson(jsonDecode(response.body));
  }
}
```

### 2. Dynamic UI Rendering

```dart
class DynamicRewardsWidget extends StatelessWidget {
  final String page;
  final String section;
  final String userId;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UIContentResponse>(
      future: RewardsService.getUIContent(
        page: page,
        section: section,
        userId: userId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final content = snapshot.data!;
          
          return Column(
            children: [
              // Render Ads
              if (content.ads.isNotEmpty)
                AdBannerWidget(ads: content.ads),
              
              // Render Offers
              if (content.offers.isNotEmpty)
                OffersWidget(offers: content.offers),
              
              // Render Personalized Rewards
              if (content.personalizedRewards.isNotEmpty)
                PersonalizedRewardsWidget(rewards: content.personalizedRewards),
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### 3. Reward Processing

```dart
class BookingService {
  static Future<void> processBookingReward({
    required String userId,
    required double amount,
    required String bookingId,
    String? serviceCategory,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/api/rewards/process-booking-reward'),
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'user_id': userId,
        'booking_amount': amount.toString(),
        'booking_id': bookingId,
        'service_category': serviceCategory,
      },
    );
  }
}
```

## 🛠️ Admin Management

### 1. Creating Reward Rules

```python
# Example: Create a booking reward rule
reward_data = {
    "name": "Booking Points",
    "description": "Earn 10 points per ₹500 spent",
    "rule_config": {
        "perSpend": 10,
        "minAmount": 500,
        "type": "points"
    },
    "page": "booking",
    "section": "summary",
    "audience": "all",
    "priority": 1
}

response = requests.post(
    "http://localhost:8000/api/rewards/rewards",
    json=reward_data,
    headers={"Authorization": f"Bearer {admin_token}"}
)
```

### 2. Creating Personalized Rewards

```python
# Example: Create birthday gift
personalized_reward = {
    "user_id": "123",
    "title": "Birthday Gift 🎁",
    "custom_message": "Happy Birthday! Here's 100 bonus points!",
    "reward_type": "points",
    "reward_value": 100,
    "trigger_type": "birthday",
    "valid_from": "2024-01-15",
    "valid_till": "2024-01-31"
}

response = requests.post(
    "http://localhost:8000/api/rewards/personalized-rewards",
    json=personalized_reward,
    headers={"Authorization": f"Bearer {admin_token}"}
)
```

### 3. Managing Loyalty Tiers

```python
# Example: Create loyalty tier
tier_data = {
    "tier_name": "gold",
    "min_points": 1000,
    "benefits_json": {
        "discount": 10,
        "priority_booking": True,
        "free_service": "skin_check"
    },
    "priority": 3
}

response = requests.post(
    "http://localhost:8000/api/rewards/loyalty-tiers",
    json=tier_data,
    headers={"Authorization": f"Bearer {admin_token}"}
)
```

## 🧪 Testing

### 1. Unit Tests

```python
import pytest
from service.rewards_engine_service import RewardsEngineService
from dto.rewards_schema import UIContentRequest

def test_get_ui_content():
    # Setup
    service = RewardsEngineService(db_session)
    request = UIContentRequest(
        page="home",
        section="banner",
        user_id="123"
    )
    
    # Execute
    result = service.get_ui_content(request)
    
    # Assert
    assert result is not None
    assert isinstance(result.ads, list)
    assert isinstance(result.offers, list)
    assert isinstance(result.rewards, list)
```

### 2. Integration Tests

```python
def test_booking_reward_processing():
    # Setup
    service = RewardsEngineService(db_session)
    
    # Execute
    result = service.process_booking_reward(
        user_id="123",
        booking_amount=1000,
        booking_id="BOOK001",
        service_category="hair"
    )
    
    # Assert
    assert result["success"] is True
    assert result["total_points_earned"] > 0
    assert len(result["rewards_given"]) > 0
```

### 3. API Tests

```python
def test_ui_content_endpoint():
    response = client.post(
        "/api/rewards/ui-content",
        json={
            "page": "home",
            "section": "banner",
            "user_id": "123"
        },
        headers={"Authorization": f"Bearer {test_token}"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "ads" in data
    assert "offers" in data
    assert "rewards" in data
```

## 🚀 Deployment

### 1. Database Migration

```bash
# Run the migration to create rewards tables
cd BackendMobileAPP
alembic upgrade head
```

### 2. Environment Variables

Add these to your `.env` file:
```env
# Rewards System Configuration
REWARDS_ENABLED=true
DEFAULT_POINTS_MULTIPLIER=1.0
MAX_POINTS_PER_BOOKING=1000
LOYALTY_TIER_UPGRADE_ENABLED=true
```

### 3. Initial Data Setup

```python
# Create default loyalty tiers
default_tiers = [
    {
        "tier_name": "bronze",
        "min_points": 0,
        "benefits_json": {"discount": 0, "priority_booking": False},
        "priority": 1
    },
    {
        "tier_name": "silver",
        "min_points": 500,
        "benefits_json": {"discount": 5, "priority_booking": True},
        "priority": 2
    },
    {
        "tier_name": "gold",
        "min_points": 1000,
        "benefits_json": {"discount": 10, "priority_booking": True, "free_service": "skin_check"},
        "priority": 3
    },
    {
        "tier_name": "platinum",
        "min_points": 2500,
        "benefits_json": {"discount": 15, "priority_booking": True, "free_service": "consultation"},
        "priority": 4
    }
]

# Create default reward rules
default_rules = [
    {
        "name": "Booking Points",
        "rule_config": {"perSpend": 10, "minAmount": 500},
        "page": "booking",
        "section": "summary",
        "audience": "all"
    },
    {
        "name": "First Booking Bonus",
        "rule_config": {"flatPoints": 100, "minAmount": 0},
        "page": "booking",
        "section": "summary",
        "audience": "first_time_users"
    }
]
```

## 📊 Analytics & Monitoring

### 1. Key Metrics

- **Reward Redemption Rate**: Percentage of rewards claimed
- **User Engagement**: Points earned vs. redeemed
- **Tier Distribution**: Users in each loyalty tier
- **Offer Performance**: Click-through and conversion rates
- **Referral Success**: Referral completion rate

### 2. Dashboard Endpoints

```http
GET /api/rewards/statistics/rewards
GET /api/rewards/statistics/offers
GET /api/rewards/user-statistics/{user_id}
```

## 🔧 Troubleshooting

### Common Issues

1. **No rewards showing**: Check if rewards are active and within valid date range
2. **Points not updating**: Verify user loyalty record exists
3. **Offers not appearing**: Check audience targeting and usage limits
4. **Migration errors**: Ensure database supports JSON columns

### Debug Endpoints

```http
GET /api/rewards/debug/user-loyalty/{user_id}
GET /api/rewards/debug/active-rules
GET /api/rewards/debug/available-offers?user_id={user_id}
```

## 📞 Support

For technical support or questions about the rewards system:

1. Check the logs in `BackendMobileAPP/logs/`
2. Review the API documentation at `/docs`
3. Test endpoints using the provided examples
4. Contact the development team for complex issues

---

**🎉 Congratulations!** You now have a complete, scalable rewards and engagement ecosystem that can handle millions of users and provide personalized experiences for each one.
