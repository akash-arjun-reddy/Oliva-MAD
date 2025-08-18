"""Add guest_id column to users table

Revision ID: 94c659cab8aa
Revises: cec54d4a7fce
Create Date: 2025-06-03 00:58:13.696181

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '94c659cab8aa'
down_revision: Union[str, None] = 'cec54d4a7fce'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.add_column('users', sa.Column('guest_id', sa.Integer(), nullable=True))


def downgrade():
    op.drop_column('users', 'guest_id')