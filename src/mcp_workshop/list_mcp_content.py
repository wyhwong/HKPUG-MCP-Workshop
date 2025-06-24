from fastmcp import Client

from mcp_workshop import env


MCP_FS_URL = f"http://localhost:{env.MCP_FS_PORT}/sse"
MCP_PG_URL = f"http://localhost:{env.MCP_PG_PORT}/sse"


async def main():
    for url in [MCP_FS_URL, MCP_PG_URL]:

        try:
            async with Client(url) as client:
                tools = await client.list_tools()
                print(f"Available tools: {tools}")

                print("-" * 20)

                resources = await client.list_resources()
                print(f"Available resources: {resources}")

                print("-" * 20)

                prompts = await client.list_prompts()
                print(f"Available prompts: {prompts}")

        except Exception as e:
            print(f"Error connecting to {url}: {e}")


if __name__ == "__main__":
    import asyncio

    asyncio.run(main())
