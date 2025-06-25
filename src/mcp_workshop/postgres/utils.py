from typing import Optional

from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm.session import sessionmaker

from mcp_workshop.postgres.schema import PhotoDescription


def load_all_photo_descriptions(session_factory: sessionmaker) -> list[dict]:
    """Load all photo descriptions from the database."""

    with session_factory() as conn:
        records = conn.query(PhotoDescription).all()

    return [{"filepath": r.filepath, "description": r.description} for r in records]


def insert_photo_description_record(session_factory: sessionmaker, filepath: str, description: str) -> bool:
    """Insert a photo description into the database."""

    statement = (
        insert(PhotoDescription)
        .values(
            filepath=filepath,
            description=description,
        )
        .on_conflict_do_update(
            index_elements=["filepath"],
            set_=dict(description=description),
        )
    )

    with session_factory() as conn:
        try:
            conn.execute(statement)
            conn.commit()
            return True
        except Exception:
            conn.rollback()
            return False


def get_photo_description(session_factory: sessionmaker, filepath: str) -> Optional[str]:
    """Get a photo description by its file path."""

    with session_factory() as conn:
        record = conn.query(PhotoDescription).filter_by(filepath=filepath).first()

    if record:
        return record.description
