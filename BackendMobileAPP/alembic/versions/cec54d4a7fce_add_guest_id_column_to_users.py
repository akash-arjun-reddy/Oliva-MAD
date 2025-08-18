"""add guest_id column to users

Revision ID: cec54d4a7fce
Revises: f9afb773e980
Create Date: 2025-06-02 14:50:40.540750

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'cec54d4a7fce'
down_revision: Union[str, None] = 'f9afb773e980'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('users', sa.Column('guest_id', sa.Integer(), nullable=True))


def downgrade() -> None:
    op.drop_column('users', 'guest_id')
