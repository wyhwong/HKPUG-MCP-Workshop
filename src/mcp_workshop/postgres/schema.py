from sqlalchemy import Column, String
from sqlalchemy.engine import Engine
from sqlalchemy.orm import declarative_base

from mcp_workshop.postgres.constants import TableName


Base = declarative_base()


class PhotoDescription(Base):

    __tablename__ = TableName.PHOTO_DESCRIPTION

    filepath = Column(String, primary_key=True, nullable=False)
    description = Column(String, nullable=False)


def create_tables(engine: Engine) -> None:
    """Create tables in the database."""

    Base.metadata.create_all(engine)
