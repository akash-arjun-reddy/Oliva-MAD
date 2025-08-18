"""Add guest_code column to users

Revision ID: 7e1aef80bac2
Revises: 5eb1e1ec1ef8
Create Date: 2025-06-02 13:48:25.208771

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '7e1aef80bac2'
down_revision: Union[str, None] = '5eb1e1ec1ef8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
