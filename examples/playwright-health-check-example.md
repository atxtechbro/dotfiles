# Playwright Health Check Example

This example shows how to use Playwright MCP tools within Claude Code to perform comprehensive health checks on web services.

## Basic Health Check

When you want to verify a web service is running (e.g., the MCP dashboard), you can use these Playwright MCP commands:

```bash
# 1. Navigate to the service
browser_navigate url: "http://localhost:8080"

# 2. Take a screenshot for visual confirmation
browser_take_screenshot filename: "dashboard-health-check.png"

# 3. Check the page content
browser_snapshot
```

## Advanced Health Check

For more comprehensive checks, you can:

```bash
# 1. Navigate and wait for specific content
browser_navigate url: "http://localhost:8080"
browser_wait_for text: "MCP Dashboard"

# 2. Verify specific elements exist
browser_snapshot
# Look for specific UI elements in the snapshot

# 3. Take a full-page screenshot
browser_take_screenshot fullPage: true filename: "dashboard-full.png"

# 4. Check console for errors
browser_console_messages
```

## Integration with start-mcp-dashboard

After starting the dashboard with `start-mcp-dashboard start`, you can run these Playwright checks to visually confirm the dashboard is working correctly. This provides more confidence than a simple HTTP check.

## Benefits over curl

- Visual confirmation that the page renders correctly
- Can detect JavaScript errors
- Can verify specific content is present
- Provides screenshots for debugging
- Can interact with the page if needed

## Usage in Scripts

While these commands are designed for interactive use in Claude Code, you can document the expected health check procedure in your scripts, as shown in the `bin/check-web-health` script.