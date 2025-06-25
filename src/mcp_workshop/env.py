import os


# For first MCP
MCP_FS_PORT = int(os.getenv("MCP_FS_PORT", "8000"))
STORAGE_PATH = os.getenv("STORAGE_PATH", "/tmp/storage")

# For second MCP
MCP_PG_PORT = int(os.getenv("MCP_PG_PORT", "8001"))
POSTGRES_HOST = os.getenv("POSTGRES_HOST", "localhost")
POSTGRES_PORT = int(os.getenv("POSTGRES_PORT", "5432"))
POSTGRES_USERNAME = os.getenv("POSTGRES_USERNAME", "postgres")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "postgres")
POSTGRES_DATABASE = os.getenv("POSTGRES_DATABASE", "postgres")
