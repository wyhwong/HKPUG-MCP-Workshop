from fastmcp import FastMCP
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from mcp_workshop import env
from mcp_workshop.postgres.schema import create_tables
from mcp_workshop.postgres.utils import (
    get_photo_description,
    insert_photo_description_record,
    load_all_photo_descriptions,
)


DB_URL = f"postgresql://{env.POSTGRES_USERNAME}:{env.POSTGRES_PASSWORD}@{env.POSTGRES_HOST}:{env.POSTGRES_PORT}/{env.POSTGRES_DATABASE}"
ENGINE = create_engine(DB_URL)
create_tables(ENGINE)
SESSION_FACTORY = sessionmaker(bind=ENGINE)


INSTRUCTIONS = """
This server provides a simple interface to interact with a PostgreSQL database.
Call insert_photo_description_to_database(filepath, description) to insert a photo description into the database.
Call list_photo_descriptions_in_database() to list all photo descriptions in the database.
Call get_photo_description_from_database(filepath) to get a photo description by its file path.
"""

###############################################################################
#                 Please implement your MCP server below.                     #
# Note:                                                                       #
# - You only need to modify this file,                                        #
#     all other files should be left unchanged.                               #
# - Try to start from the INSTRUCTIONS above,                                 #
#     and implement the mentioned functions.                                  #
# - You may refer to mcp_fs.py as an example to write a MCP server.           #
###############################################################################
