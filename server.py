# server.py
from mcp.server.fastmcp import FastMCP
import clickhouse_connect
import os

# Create an MCP server
mcp = FastMCP("OmopServer")

@mcp.tool()
async def query_omop_database(query: str) -> dict:
    """Query the OMOP database and return results as a dictionary with column names as keys"""

    client = await clickhouse_connect.get_async_client(
        host=os.getenv("CLICKHOUSE_HOST", "localhost"), 
        port=os.getenv("CLICKHOUSE_PORT", 8123),
        username=os.getenv("CLICKHOUSE_USER", "default"), 
        password=os.getenv("CLICKHOUSE_PASSWORD", "default"),
        database=os.getenv("CLICKHOUSE_DB", "omop")
    )
    
    result = await client.query(query)
    # Create a list of dictionaries where each dictionary represents a row
    # with column names as keys
    return [dict(zip(result.column_names, row)) for row in result.result_rows]


if __name__ == "__main__":
    mcp.run()
