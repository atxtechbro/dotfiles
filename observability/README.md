# Claude Code Observability with OpenTelemetry

This directory contains the complete observability stack for monitoring Claude Code usage with OpenTelemetry, Prometheus, and Grafana.

## What This Replaces

This OpenTelemetry-based setup replaces the previous MLflow tracking implementation, providing:
- Real-time metrics and dashboards (vs. post-session analysis)
- Industry-standard observability stack
- Better performance and lower overhead
- Native integration with Claude Code

## Architecture

```
Claude Code (OTel SDK)
    ↓ OTLP (gRPC)
OpenTelemetry Collector
    ↓ Prometheus format
Prometheus (metrics storage)
    ↓ PromQL
Grafana (visualization)
```

## Quick Start

### 1. Start the Observability Stack

```bash
start-observability start
```

This launches:
- **OpenTelemetry Collector** - Receives telemetry from Claude Code
- **Prometheus** - Time-series database for metrics
- **Grafana** - Dashboards and visualization

### 2. Access Dashboards

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090

### 3. Use Claude Code Normally

Claude Code is already configured to send telemetry to the stack via `.claude/settings.json`.

## Available Metrics

Claude Code exports these metrics automatically:

| Metric | Description |
|--------|-------------|
| `claude_code.session.count` | Total sessions started |
| `claude_code.lines_of_code.count` | Lines of code modified |
| `claude_code.token.usage` | Token consumption (input/output/cache) |
| `claude_code.cost.usage` | Session costs in USD |
| `claude_code.commit.count` | Git commits created |
| `claude_code.pull_request.count` | Pull requests created |
| `claude_code.code_edit_tool.decision` | Tool permission decisions |
| `claude_code.active_time.total` | Active usage time in seconds |

## Dashboards

### Claude Code Overview

Pre-configured dashboard showing:
- Session activity rates
- Token usage by type (input/output/cache)
- Cost tracking over time
- Git activity (commits and PRs)
- Tool permission decision trends
- Lines of code changes

Access at: http://localhost:3000/d/claude-code-overview

## Configuration

### Claude Code Settings

OTel configuration is in `.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4317",
    "OTEL_METRIC_EXPORT_INTERVAL": "10000",
    "OTEL_LOGS_EXPORT_INTERVAL": "5000",
    "OTEL_RESOURCE_ATTRIBUTES": "team=dotfiles,env=dev,service.name=claude-code"
  }
}
```

### Customizing Resource Attributes

Add custom metadata to all metrics/logs by editing `OTEL_RESOURCE_ATTRIBUTES`:

```bash
"OTEL_RESOURCE_ATTRIBUTES": "team=platform,env=prod,user=alice"
```

### Enabling User Prompt Logging

By default, user prompts are redacted in logs (`OTEL_LOG_USER_PROMPTS` is set to `"0"`). To include full prompts, change the value in `.claude/settings.json`:

```json
"OTEL_LOG_USER_PROMPTS": "1"
```

**Warning**: Only enable if you're comfortable logging sensitive data. This will log the complete text of all your prompts to Claude Code.

## Managing the Stack

```bash
# Start (or check if running)
start-observability start

# Stop
start-observability stop

# Restart
start-observability restart

# Check status
start-observability status
```

## Data Persistence

Metrics and dashboards persist across restarts via Docker volumes:
- `prometheus-data` - Prometheus time-series data
- `grafana-data` - Grafana dashboards and settings

To reset all data:

```bash
docker compose down -v  # WARNING: Deletes all historical data
```

## Querying Metrics

### In Prometheus (http://localhost:9090)

Example queries:

```promql
# Total sessions today
increase(claude_code_session_count_total[24h])

# Token usage rate
rate(claude_code_token_usage_total[5m])

# Hourly cost
increase(claude_code_cost_usage_total[1h])

# Permission accept rate
rate(claude_code_code_edit_tool_decision_total{decision="accept"}[5m])
```

### In Grafana

Use the pre-built "Claude Code Overview" dashboard or create custom panels using PromQL.

## Troubleshooting

### No Metrics Showing Up

1. Check OTel Collector is running:
   ```bash
   docker logs claude-otel-collector
   ```

2. Verify Claude Code is sending telemetry:
   ```bash
   # Check collector logs for incoming data
   docker logs claude-otel-collector -f
   ```

3. Confirm Prometheus is scraping:
   ```bash
   # Visit Prometheus targets page
   open http://localhost:9090/targets
   ```

### Grafana Dashboard Empty

1. Verify Prometheus datasource is configured:
   - Grafana → Configuration → Data Sources → Prometheus
   - Should be at `http://prometheus:9090`

2. Check if metrics exist in Prometheus:
   - Go to http://localhost:9090
   - Try query: `claude_code_session_count_total`

### High Resource Usage

#### Collector Memory Issues

If you see OOM errors or the collector crashing, adjust memory limits in `observability/otel-collector-config.yml`:

```yaml
memory_limiter:
  check_interval: 1s
  limit_mib: 2048        # Increase for high-volume telemetry (default: 2048)
  spike_limit_mib: 512   # Temporary spike allowance (default: 512)
```

**Tuning Guidelines**:
- **Light usage** (< 100 sessions/day): 1024 MiB is sufficient
- **Moderate usage** (100-500 sessions/day): 2048 MiB (default)
- **Heavy usage** (> 500 sessions/day): 4096+ MiB
- Monitor collector memory: `docker stats claude-otel-collector`

#### Reduce Export Frequency

Lower telemetry volume in `.claude/settings.json`:

```json
"OTEL_METRIC_EXPORT_INTERVAL": "30000",  // 30 seconds vs 10
"OTEL_LOGS_EXPORT_INTERVAL": "15000"     // 15 seconds vs 5
```

## Advanced Configuration

### Adding Additional Exporters

Edit `observability/otel-collector-config.yml` to add exporters for:
- Remote OTLP endpoints
- Cloud providers (DataDog, New Relic, etc.)
- Other observability backends

### Cardinality Control

To reduce storage costs, disable high-cardinality attributes:

```json
"OTEL_METRICS_INCLUDE_SESSION_ID": "false",
"OTEL_METRICS_INCLUDE_ACCOUNT_UUID": "false"
```

### Custom Dashboards

1. Create dashboard in Grafana UI
2. Export JSON via Share → Export
3. Save to `observability/grafana/dashboards/`
4. Restart Grafana to auto-provision

## Migration from MLflow

This setup completely replaces the previous MLflow tracking system. Key differences:

| Feature | MLflow | OpenTelemetry + Grafana |
|---------|--------|------------------------|
| **Timing** | Post-session | Real-time |
| **Setup** | Python + MLflow UI | Docker compose |
| **Standards** | MLflow-specific | OpenTelemetry (industry standard) |
| **Metrics** | Custom parsing | Native Claude Code metrics |
| **Dashboards** | MLflow UI | Grafana (customizable) |
| **Export** | File-based | OTLP protocol |

## Resources

- [Claude Code OTel Docs](https://docs.claude.com/en/docs/claude-code/monitoring-usage.md)
- [OpenTelemetry](https://opentelemetry.io/)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
