import os

from fastmcp import FastMCP
from fastmcp.utilities.types import Image

from mcp_workshop import env
from mcp_workshop.utils.fs import (
    create_folder,
    list_files,
    list_folders,
    load_image_as_bytes,
    move_file,
)


if not os.path.exists(env.STORAGE_PATH):
    os.makedirs(env.STORAGE_PATH)


INSTRUCTIONS = """
This server provides a simple interface to interact with file system and postgresDB.
Call create_album() to create a new album.
Call list_albums() to list all albums.
Call list_images(album_name) to list all images in a specific album.
Call load_image(filepath) to load an image from the specified album.
Call add_image_to_album(album_name, filepath) to add an image to the specified album.
"""

mcp = FastMCP(
    name="AlbumAssistant",
    instructions=INSTRUCTIONS,
    on_duplicate_tools="error",
)


@mcp.tool()
def list_albums() -> str:
    """List all albums in the storage path."""

    return str(list_folders())


@mcp.tool()
def create_album(album_name: str) -> str:
    """Create a new album with the given name."""

    return create_folder(album_name)


@mcp.tool()
def list_images(album_name: str) -> str:
    """List all images in the specified album."""

    return str(list_files(album_name))


@mcp.tool()
def load_image(filepath: str) -> Image:
    """Load an image from the given file path."""

    return Image(data=load_image_as_bytes(filepath), format="jpeg")


@mcp.tool()
def add_image_to_album(album_name: str, filepath: str) -> str:
    """Add an image to the specified album."""

    return move_file(filepath, album_name)


if __name__ == "__main__":
    mcp.run(transport="sse", port=env.MCP_PORT)
