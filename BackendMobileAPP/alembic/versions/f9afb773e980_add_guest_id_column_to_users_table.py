"""add guest_id column to users table

Revision ID: f9afb773e980
Revises: b58b888c7f6d
Create Date: 2025-06-02 14:43:55.681731

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f9afb773e980'
down_revision: Union[str, None] = 'b58b888c7f6d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.add_column('users', sa.Column('guest_id', sa.String(length=100), nullable=True))

def downgrade():
    op.drop_column('users', 'guest_id')
