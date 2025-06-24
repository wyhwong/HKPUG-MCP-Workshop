from sqlalchemy import Column, Integer, String
from sqlalchemy.engine import Engine
from sqlalchemy.ext.declarative import declarative_base


Base = declarative_base()


class PhotoDescription(Base):

    __tablename__ = "photo_description"

    id = Column(Integer, primary_key=True, autoincrement=True)
    filepath = Column(String, nullable=False)
    description = Column(String)


def create_tables(engine: Engine) -> None:
    """Create tables in the database."""

    Base.metadata.create_all(engine)
