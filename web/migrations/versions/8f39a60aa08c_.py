"""empty message

Revision ID: 8f39a60aa08c
Revises: 
Create Date: 2023-09-16 08:52:16.286653

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '8f39a60aa08c'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('location',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('latitude', sa.Float(), nullable=True),
    sa.Column('longitude', sa.Float(), nullable=True),
    sa.Column('radius', sa.Float(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('protocols',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('protocol', sa.String(length=80), nullable=True),
    sa.Column('location_id', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['location_id'], ['location.id'], name='fk_location_id'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('messages',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('message', sa.String(length=80), nullable=True),
    sa.Column('protocol_id', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['protocol_id'], ['protocols.id'], name='fk_protocol_id'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('phone',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('phone_number', sa.String(length=80), nullable=True),
    sa.Column('protocol_id', sa.Integer(), nullable=True),
    sa.Column('location_id', sa.Integer(), nullable=True),
    sa.Column('message', sa.String(length=1000), nullable=True),
    sa.ForeignKeyConstraint(['location_id'], ['location.id'], name='fk_location_id'),
    sa.ForeignKeyConstraint(['protocol_id'], ['protocols.id'], name='fk_protocol_id'),
    sa.PrimaryKeyConstraint('id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('phone')
    op.drop_table('messages')
    op.drop_table('protocols')
    op.drop_table('location')
    # ### end Alembic commands ###
