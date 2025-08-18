"""merge guest_code migrations

Revision ID: b58b888c7f6d
Revises: ad4b82aecdba, 7e1aef80bac2
Create Date: 2025-06-02 13:59:48.663045

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b58b888c7f6d'
down_revision: Union[str, None] = ('ad4b82aecdba', '7e1aef80bac2')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
