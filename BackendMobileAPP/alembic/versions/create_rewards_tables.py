"""Create rewards and engagement tables

Revision ID: rewards_001
Revises: 7e1aef80bac2
Create Date: 2024-01-15 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'rewards_001'
down_revision = '7e1aef80bac2'
branch_labels = None
depends_on = None


def upgrade():
    # Create enum types
    op.execute("CREATE TYPE audiencetype AS ENUM ('all', 'first_time_users', 'loyalty_silver', 'loyalty_gold', 'loyalty_platinum', 'new_users', 'returning_users', 'vip_users')")
    op.execute("CREATE TYPE pagetype AS ENUM ('home', 'booking', 'profile', 'payment', 'shop', 'consultation', 'dashboard', 'notifications')")
    op.execute("CREATE TYPE sectiontype AS ENUM ('banner', 'popup', 'footer', 'sidebar', 'summary', 'header', 'card', 'modal')")
    op.execute("CREATE TYPE rewardtype AS ENUM ('points', 'discount', 'free_service', 'gift', 'cashback', 'referral_bonus', 'birthday_gift', 'milestone_reward')")
    op.execute("CREATE TYPE offertype AS ENUM ('percentage_discount', 'flat_discount', 'free_service', 'buy_one_get_one', 'bundle_offer', 'seasonal_offer')")
    op.execute("CREATE TYPE loyaltytier AS ENUM ('bronze', 'silver', 'gold', 'platinum', 'diamond')")
    op.execute("CREATE TYPE statustype AS ENUM ('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed')")

    # Create rewards_points table
    op.create_table('rewards_points',
        sa.Column('reward_id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('rule_json', sa.JSON(), nullable=False),
        sa.Column('page', sa.String(length=50), nullable=False),
        sa.Column('section', sa.String(length=50), nullable=False),
        sa.Column('audience', sa.String(length=100), nullable=False),
        sa.Column('valid_from', sa.Date(), nullable=False),
        sa.Column('valid_till', sa.Date(), nullable=True),
        sa.Column('priority', sa.Integer(), nullable=True),
        sa.Column('status', sa.Enum('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('reward_id')
    )
    op.create_index(op.f('ix_rewards_points_reward_id'), 'rewards_points', ['reward_id'], unique=False)

    # Create referrals table
    op.create_table('referrals',
        sa.Column('referral_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.String(length=50), nullable=False),
        sa.Column('referred_user_id', sa.String(length=50), nullable=False),
        sa.Column('reward_points', sa.Integer(), nullable=True),
        sa.Column('discount_amount', sa.DECIMAL(precision=10, scale=2), nullable=True),
        sa.Column('status', sa.Enum('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('referral_id')
    )
    op.create_index(op.f('ix_referrals_referral_id'), 'referrals', ['referral_id'], unique=False)

    # Create loyalty_tiers table
    op.create_table('loyalty_tiers',
        sa.Column('tier_id', sa.Integer(), nullable=False),
        sa.Column('tier_name', sa.String(length=50), nullable=False),
        sa.Column('min_points', sa.Integer(), nullable=False),
        sa.Column('benefits_json', sa.JSON(), nullable=False),
        sa.Column('priority', sa.Integer(), nullable=True),
        sa.Column('status', sa.Enum('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('tier_id')
    )
    op.create_index(op.f('ix_loyalty_tiers_tier_id'), 'loyalty_tiers', ['tier_id'], unique=False)

    # Create joining_bonus table
    op.create_table('joining_bonus',
        sa.Column('bonus_id', sa.Integer(), nullable=False),
        sa.Column('title', sa.String(length=100), nullable=False),
        sa.Column('points', sa.Integer(), nullable=True),
        sa.Column('discount_amount', sa.DECIMAL(precision=10, scale=2), nullable=True),
        sa.Column('audience', sa.String(length=50), nullable=True),
        sa.Column('valid_from', sa.Date(), nullable=False),
        sa.Column('valid_till', sa.Date(), nullable=True),
        sa.Column('status', sa.Enum('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('bonus_id')
    )
    op.create_index(op.f('ix_joining_bonus_bonus_id'), 'joining_bonus', ['bonus_id'], unique=False)

    # Create prizes_gifts table
    op.create_table('prizes_gifts',
        sa.Column('gift_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.String(length=50), nullable=False),
        sa.Column('title', sa.String(length=100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('reward_points', sa.Integer(), nullable=True),
        sa.Column('discount_amount', sa.DECIMAL(precision=10, scale=2), nullable=True),
        sa.Column('gift_item', sa.String(length=100), nullable=True),
        sa.Column('valid_from', sa.Date(), nullable=False),
        sa.Column('valid_till', sa.Date(), nullable=True),
        sa.Column('status', sa.Enum('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('gift_id')
    )
    op.create_index(op.f('ix_prizes_gifts_gift_id'), 'prizes_gifts', ['gift_id'], unique=False)

    # Create offers_discounts table
    op.create_table('offers_discounts',
        sa.Column('offer_id', sa.Integer(), nullable=False),
        sa.Column('title', sa.String(length=100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('page', sa.String(length=50), nullable=False),
        sa.Column('section', sa.String(length=50), nullable=False),
        sa.Column('audience', sa.String(length=100), nullable=False),
        sa.Column('conditions_json', sa.JSON(), nullable=False),
        sa.Column('discount_percentage', sa.DECIMAL(precision=5, scale=2), nullable=True),
        sa.Column('discount_amount', sa.DECIMAL(precision=10, scale=2), nullable=True),
        sa.Column('valid_from', sa.Date(), nullable=False),
        sa.Column('valid_till', sa.Date(), nullable=True),
        sa.Column('priority', sa.Integer(), nullable=True),
        sa.Column('status', sa.Enum('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('offer_id')
    )
    op.create_index(op.f('ix_offers_discounts_offer_id'), 'offers_discounts', ['offer_id'], unique=False)

    # Create ads table
    op.create_table('ads',
        sa.Column('ad_id', sa.Integer(), nullable=False),
        sa.Column('title', sa.String(length=100), nullable=False),
        sa.Column('image_url', sa.String(length=255), nullable=False),
        sa.Column('redirect_url', sa.String(length=255), nullable=True),
        sa.Column('page', sa.String(length=50), nullable=False),
        sa.Column('section', sa.String(length=50), nullable=False),
        sa.Column('audience', sa.String(length=100), nullable=False),
        sa.Column('valid_from', sa.Date(), nullable=False),
        sa.Column('valid_till', sa.Date(), nullable=True),
        sa.Column('priority', sa.Integer(), nullable=True),
        sa.Column('center_id', sa.String(length=50), nullable=True),
        sa.Column('status', sa.Enum('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), nullable=True),
        sa.Column('click_count', sa.Integer(), nullable=True),
        sa.Column('view_count', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('ad_id')
    )
    op.create_index(op.f('ix_ads_ad_id'), 'ads', ['ad_id'], unique=False)

    # Create personalized_rewards table
    op.create_table('personalized_rewards',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.String(length=50), nullable=False),
        sa.Column('reward_id', sa.Integer(), nullable=True),
        sa.Column('custom_message', sa.String(length=255), nullable=True),
        sa.Column('valid_from', sa.Date(), nullable=False),
        sa.Column('valid_till', sa.Date(), nullable=True),
        sa.Column('status', sa.Enum('active', 'inactive', 'expired', 'redeemed', 'pending', 'completed', name='statustype'), nullable=True),
        sa.Column('reward_type', sa.String(length=50), nullable=True),
        sa.Column('reward_value', sa.DECIMAL(precision=10, scale=2), nullable=True),
        sa.Column('trigger_type', sa.String(length=100), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['reward_id'], ['rewards_points.reward_id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_personalized_rewards_id'), 'personalized_rewards', ['id'], unique=False)

    # Create user_loyalty table
    op.create_table('user_loyalty',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.String(length=50), nullable=False),
        sa.Column('loyalty_tier', sa.String(length=50), nullable=True),
        sa.Column('total_points_earned', sa.Integer(), nullable=True),
        sa.Column('total_points_redeemed', sa.Integer(), nullable=True),
        sa.Column('current_points_balance', sa.Integer(), nullable=True),
        sa.Column('points_to_next_tier', sa.Integer(), nullable=True),
        sa.Column('tier_upgraded_at', sa.DateTime(), nullable=True),
        sa.Column('total_bookings', sa.Integer(), nullable=True),
        sa.Column('total_spent', sa.DECIMAL(precision=10, scale=2), nullable=True),
        sa.Column('last_booking_date', sa.DateTime(), nullable=True),
        sa.Column('referral_count', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id')
    )
    op.create_index(op.f('ix_user_loyalty_id'), 'user_loyalty', ['id'], unique=False)

    # Create reward_transactions table
    op.create_table('reward_transactions',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.String(length=50), nullable=False),
        sa.Column('reward_id', sa.Integer(), nullable=True),
        sa.Column('personalized_reward_id', sa.Integer(), nullable=True),
        sa.Column('transaction_type', sa.String(length=50), nullable=False),
        sa.Column('points_amount', sa.Integer(), nullable=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('booking_id', sa.String(length=100), nullable=True),
        sa.Column('order_id', sa.String(length=100), nullable=True),
        sa.Column('points_before', sa.Integer(), nullable=True),
        sa.Column('points_after', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['personalized_reward_id'], ['personalized_rewards.id'], ),
        sa.ForeignKeyConstraint(['reward_id'], ['rewards_points.reward_id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_reward_transactions_id'), 'reward_transactions', ['id'], unique=False)

    # Create offer_usages table
    op.create_table('offer_usages',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.String(length=50), nullable=False),
        sa.Column('offer_id', sa.Integer(), nullable=False),
        sa.Column('booking_id', sa.String(length=100), nullable=True),
        sa.Column('order_id', sa.String(length=100), nullable=True),
        sa.Column('discount_applied', sa.DECIMAL(precision=10, scale=2), nullable=True),
        sa.Column('used_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['offer_id'], ['offers_discounts.offer_id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_offer_usages_id'), 'offer_usages', ['id'], unique=False)

    # Create user_reward_claims table
    op.create_table('user_reward_claims',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.String(length=50), nullable=False),
        sa.Column('reward_type', sa.String(length=50), nullable=False),
        sa.Column('reward_id', sa.Integer(), nullable=True),
        sa.Column('claimed_at', sa.DateTime(), nullable=True),
        sa.Column('points_earned', sa.Integer(), nullable=True),
        sa.Column('discount_earned', sa.DECIMAL(precision=10, scale=2), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_user_reward_claims_id'), 'user_reward_claims', ['id'], unique=False)

    # Create reward_rules table
    op.create_table('reward_rules',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('rule_name', sa.String(length=100), nullable=False),
        sa.Column('rule_type', sa.String(length=50), nullable=False),
        sa.Column('conditions_json', sa.JSON(), nullable=False),
        sa.Column('reward_json', sa.JSON(), nullable=False),
        sa.Column('priority', sa.Integer(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_reward_rules_id'), 'reward_rules', ['id'], unique=False)

    # Create loyalty_tier_benefits table
    op.create_table('loyalty_tier_benefits',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('tier_name', sa.String(length=50), nullable=False),
        sa.Column('benefit_type', sa.String(length=50), nullable=False),
        sa.Column('benefit_value', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_loyalty_tier_benefits_id'), 'loyalty_tier_benefits', ['id'], unique=False)


def downgrade():
    # Drop tables
    op.drop_index(op.f('ix_loyalty_tier_benefits_id'), table_name='loyalty_tier_benefits')
    op.drop_table('loyalty_tier_benefits')
    op.drop_index(op.f('ix_reward_rules_id'), table_name='reward_rules')
    op.drop_table('reward_rules')
    op.drop_index(op.f('ix_user_reward_claims_id'), table_name='user_reward_claims')
    op.drop_table('user_reward_claims')
    op.drop_index(op.f('ix_offer_usages_id'), table_name='offer_usages')
    op.drop_table('offer_usages')
    op.drop_index(op.f('ix_reward_transactions_id'), table_name='reward_transactions')
    op.drop_table('reward_transactions')
    op.drop_index(op.f('ix_user_loyalty_id'), table_name='user_loyalty')
    op.drop_table('user_loyalty')
    op.drop_index(op.f('ix_personalized_rewards_id'), table_name='personalized_rewards')
    op.drop_table('personalized_rewards')
    op.drop_index(op.f('ix_ads_ad_id'), table_name='ads')
    op.drop_table('ads')
    op.drop_index(op.f('ix_offers_discounts_offer_id'), table_name='offers_discounts')
    op.drop_table('offers_discounts')
    op.drop_index(op.f('ix_prizes_gifts_gift_id'), table_name='prizes_gifts')
    op.drop_table('prizes_gifts')
    op.drop_index(op.f('ix_joining_bonus_bonus_id'), table_name='joining_bonus')
    op.drop_table('joining_bonus')
    op.drop_index(op.f('ix_loyalty_tiers_tier_id'), table_name='loyalty_tiers')
    op.drop_table('loyalty_tiers')
    op.drop_index(op.f('ix_referrals_referral_id'), table_name='referrals')
    op.drop_table('referrals')
    op.drop_index(op.f('ix_rewards_points_reward_id'), table_name='rewards_points')
    op.drop_table('rewards_points')

    # Drop enum types
    op.execute("DROP TYPE IF EXISTS statustype")
    op.execute("DROP TYPE IF EXISTS loyaltytier")
    op.execute("DROP TYPE IF EXISTS offertype")
    op.execute("DROP TYPE IF EXISTS rewardtype")
    op.execute("DROP TYPE IF EXISTS sectiontype")
    op.execute("DROP TYPE IF EXISTS pagetype")
    op.execute("DROP TYPE IF EXISTS audiencetype")
