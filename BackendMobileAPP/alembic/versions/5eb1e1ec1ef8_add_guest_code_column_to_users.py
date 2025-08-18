"""Add guest_code column to users

Revision ID: 5eb1e1ec1ef8
Revises: <put your current latest revision ID here, or None if first migration>
Create Date: 2025-06-02 13:45:11.797657
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '5eb1e1ec1ef8'
down_revision = None  # or put your current latest revision ID if exists
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.add_column('users', sa.Column('guest_id', sa.String(), nullable=True))
    # Optional: add unique constraint if needed
    # op.create_unique_constraint('uq_users_guest_id', 'users', ['guest_id'])

def downgrade() -> None:
    # Optional: drop unique constraint first if you created it
    # op.drop_constraint('uq_users_guest_code', 'users', type_='unique')
    op.drop_column('users', 'guest_id')
