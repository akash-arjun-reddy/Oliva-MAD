"""add guest_code to users"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'ad4b82aecdba'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('users', sa.Column('guest_code', sa.String(), nullable=True))

def downgrade():
    op.drop_column('users', 'guest_code')
