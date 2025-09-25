# MLflow Tracking Integration

This module provides MLflow tracking capabilities for our automation procedures, enabling reproducibility, observability, and debugging of all automated actions.

## Features

- **Full Metrics Tracking**: Execution time, success rates, step completion
- **Parameter Logging**: Issue numbers, file paths, context
- **Artifact Storage**: Code changes, PR descriptions, extracted frames
- **Searchable History**: Query and filter past executions
- **Visual Dashboard**: MLflow UI for exploring runs

## Installation

MLflow is installed globally via uv:

```bash
uv tool install mlflow
```

## Usage

### Starting MLflow UI

The MLflow tracking UI provides a web interface to view all tracked runs:

```bash
# Start MLflow UI (runs on http://localhost:5000)
mlflow ui --backend-store-uri ~/ppv/pillars/dotfiles/mlruns

# Or use the auto-start script
bin/start-mlflow start
```

### Interactive Claude Session Tracking

**NEW: Track your interactive Claude CLI sessions!**

Use the `claude-with-tracking` wrapper to maintain full Claude interactivity while logging to MLflow:

```bash
# Instead of:
claude "close-issue 583"

# Use:
claude-with-tracking "close-issue 583"
```

This preserves:
- ✅ Full interactivity (plan mode, permissions, comments)
- ✅ Real-time terminal output
- ✅ Ability to pause/interrupt
- ✅ Manual steering and corrections

While adding:
- 📊 Complete session transcript in MLflow
- 📈 Extracted metrics (commands, files, errors)
- 🔍 Queryable history
- ⏱️ Timing and performance data

### What Gets Tracked from Claude Sessions

The session parser extracts:
- **Commands executed**: Actual Bash commands run via Claude's tools (● Bash(...))
- **Git operations**: Git commands executed through Bash tool
- **Tool uses**: All Claude tool invocations (Bash, Read, Update, etc.)
- **User interactions**: Your prompts and inputs
- **Events**: Issue procedures and key actions

### Querying Sessions

Find specific Claude sessions in MLflow UI using search:

```
# In MLflow UI search bar:
metrics.commands_executed > 10
metrics.errors_encountered > 0
metrics.success = 1
tags.type = "claude_session"
```

## Session Metrics

Each Claude session tracks:
- **Execution metrics**: Commands run, git operations, tool uses
- **Interaction metrics**: User prompts and inputs
- **Success status**: Exit code and overall success
- **Transcripts**: Both raw and cleaned versions for review

## MLflow UI Features

### Experiments View
- List of all procedure runs
- Sort by date, duration, success
- Filter by procedure name or status

### Run Details
- Complete parameter list
- Metrics timeline
- Artifacts (logs, results)
- System metrics

### Comparison View
- Compare multiple runs side-by-side
- Identify performance trends
- Spot anomalies

### Search Examples

In the MLflow UI search bar:

```
# Find all successful runs
metrics.success = 1

# Find runs longer than 30 seconds
metrics.duration_seconds > 30

# Find close-issue runs
params.procedure_name = "close-issue"

# Find runs with specific issue
params.issue_number = "123"

# Find failed video processing
params.procedure_name = "extract-best-frame" AND metrics.success = 0
```

## Testing

Test the interactive session tracking:

```bash
# Run any Claude command with tracking
claude-with-tracking "echo 'Hello MLflow'"

# View the session in MLflow UI
open http://localhost:5000
```

## Benefits

1. **Debugging**: Full execution history with errors and artifacts
2. **Performance Monitoring**: Track execution times and success rates
3. **Reproducibility**: Complete record of parameters and environment
4. **Observability**: Visual dashboard for all automation
5. **Career Value**: Industry-standard ML engineering tool experience

## How It Works

1. **Wrapper script** (`claude-with-tracking`) runs Claude normally
2. **Session captured** with full interactivity preserved
3. **Parser** (`parse_claude_session.py`) extracts metrics after completion
4. **MLflow UI** displays session history and metrics

## Next Steps

- [ ] Add real-time procedure hooks
- [ ] Implement metric alerts
- [ ] Create custom dashboards
- [ ] Add comparison reports
- [ ] Export metrics to other systems