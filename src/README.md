# MCP Workshop (June 2025, Hong Kong Python User Group)

This documentation contains the instructions to install dependencies,
and run the MCP servers.
The repository is specifically designed for the MCP Workshop organized by the Hong Kong Python User Group in June 2025,
which took place in Auki Labs, Hong Kong.
**One should not expect the repository to be useful for anything except for learning purposes.**

## Installation

If you use uv, you may install the repository as a package by running the following commands:

```bash
# Install dependencies using uv
uv sync
# Install mcp_workshop as a package
uv pip install -e .
```

Otherwise, you can run the code in the repository by executing the following command:

```bash
pip install -r requirements.txt .
```

## Running the MCP Servers

### MCP Server (File System Interaction)

To run the MCP server for file system interaction, you may run the following command:

```bash
# If you use uv
uv run mcp_fs.py
# If you don't use uv
python3 mcp_fs.py
```

### MCP Server (Database Interaction)

To run the MCP server for database interaction, you may run the following command:

```bash
# If you use uv
uv run mcp_db.py
# If you don't use uv
python3 mcp_db.py
```

## Author
[@wyhwong](https://github.com/wyhwong)
