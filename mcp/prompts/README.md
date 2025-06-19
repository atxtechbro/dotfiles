# MCP Prompts PoC

This was my original inspiration - storing reusable prompts that can be called through Amazon Q CLI via MCP servers.

## What Works

The git MCP server now serves `@commit-message` and `@pr-description` prompts that auto-inject git context.

## How to Add Prompts to Your MCP Server

Add these MCP types to your server:
```python
from mcp.types import Prompt, PromptArgument, PromptMessage, GetPromptResult

@server.list_prompts()
async def list_prompts() -> list[Prompt]:
    return [Prompt(name="your-prompt", description="What it does")]

@server.get_prompt()  
async def get_prompt(name: str, arguments: dict | None = None) -> GetPromptResult:
    return GetPromptResult(
        description="Your prompt",
        messages=[PromptMessage(role="user", content=TextContent(type="text", text="Your prompt text"))]
    )
```

That's it. First working MCP prompts integration.
