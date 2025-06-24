from fastmcp import FastMCP
from sqlalchemy import create_engine

from mcp_workshop import env
from mcp_workshop.postgres.schema import create_tables


engine = create_engine(
    f"postgresql://{env.POSTGRES_USERNAME}:{env.POSTGRES_PASSWORD}@{env.POSTGRES_HOST}:{env.POSTGRES_PORT}/{env.POSTGRES_DATABASE}"
)
create_tables(engine)


INSTRUCTIONS = """
This server provides a simple interface to interact with a PostgreSQL database.
Call insert_photo_description(filepath, description) to insert a photo description into the database.
Call list_photo_descriptions() to list all photo descriptions in the database.
Call get_photo_description(filepath) to get a photo description by its file path.
"""

mcp = FastMCP(
    name="DatabaseAssistant",
    instructions=INSTRUCTIONS,
    on_duplicate_tools="error",
)


@mcp.tool()
def insert_photo_description(filepath: str, description: str) -> str:
    """Insert a photo description into the database."""

    raise NotImplementedError()


@mcp.tool()
def list_photo_descriptions() -> str:
    """List all photo descriptions in the database."""

    raise NotImplementedError()


@mcp.tool()
def get_photo_description(filepath: str) -> str:
    """Get a photo description by its ID."""

    raise NotImplementedError()


if __name__ == "__main__":
    mcp.run(transport="sse", port=env.MCP_PG_PORT)
