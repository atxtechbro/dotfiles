# MCP Dashboard

Real-time dashboard for monitoring MCP (Model Context Protocol) tool usage with WebSocket push updates.

## Features

- **Real-time Updates**: File watchers + WebSocket push for instant metrics
- **Rich Visualizations**: Chart.js for interactive time series and distribution charts
- **Live Tool Call Stream**: See tool executions as they happen
- **Comprehensive Metrics**:
  - Tool usage frequency and success rates
  - Execution time analysis
  - Principle adherence tracking
  - Cognitive load distribution
  - Branch activity monitoring
  - Error tracking with remediation hints

## Quick Start

```bash
# From the mcp-dashboard-go directory
go run cmd/server/main.go

# Dashboard will be available at http://localhost:8080
```

## Configuration

- `MCP_DASHBOARD_PORT`: Set custom port (default: 8080)

## Data Sources

The dashboard monitors these log files in your home directory:
- `~/mcp-tool-calls.log` - Tool execution logs
- `~/mcp-errors.log` - Error logs with remediation hints
- `~/mcp-meta-analytics.jsonl` - Metadata analytics (when available)

## Architecture

- **Go Backend**: Efficient file watching with fsnotify
- **WebSocket**: Real-time push updates to connected clients
- **Embedded Web UI**: Single binary deployment with embedded static files
- **Chart.js**: Professional data visualizations
- **Bulma CSS**: Clean, responsive UI framework

## Building

```bash
# Build standalone binary
go build -o mcp-dashboard cmd/server/main.go

# Run the binary
./mcp-dashboard
```

## Development

The dashboard follows the OSE (Outside and Slightly Elevated) principle - AI manages the complexity while users get a clean, functional dashboard for monitoring their MCP tool usage patterns.