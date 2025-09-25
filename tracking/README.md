# MLflow Tracking Integration

This module provides MLflow tracking capabilities for our automation procedures, enabling reproducibility, observability, and debugging of all automated actions.

**Now provider-agnostic!** Supports Claude Code, OpenAI Codex, GPT models, and other AI assistants.

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

### Interactive AI Session Tracking

**Track your interactive AI assistant sessions across multiple providers!**

Use the provider-specific wrappers to maintain full interactivity while logging to MLflow:

```bash
# Claude Code (Anthropic)
claude-with-tracking "close-issue 583"

# OpenAI Codex
codex-with-tracking "implement feature"

# GPT models
gpt-with-tracking "analyze code"
```

**Convention**: Each AI provider has its own tracking wrapper following the pattern `<provider>-with-tracking`. This ensures clarity about which AI assistant is being used while maintaining provider-agnostic MLflow infrastructure underneath.

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

### What Gets Tracked from AI Sessions

The session parser automatically detects the AI provider and extracts:
- **Commands executed**: Bash commands run via the AI's tools
- **Git operations**: Git commands executed through shell tools
- **Tool uses**: All AI tool invocations (bash, read, write, edit, etc.)
- **User interactions**: Your prompts and inputs
- **Events**: Issue procedures and key actions
- **Provider info**: Which AI assistant was used

Supported patterns:
- **Claude**: `● ToolName(...)` format
- **Codex**: `>>> tool: command` format
- **GPT**: `Function: tool(args)` format
- **Others**: Auto-detected or generic patterns

### Querying Sessions

Find specific AI sessions in MLflow UI using search:

```
# In MLflow UI search bar:
metrics.commands_executed > 10
metrics.errors_encountered > 0
metrics.success = 1
tags.type = "ai_session"

# Filter by provider
tags.provider = "claude_code"
tags.provider = "openai_codex"
tags.provider = "gpt"
```

## Session Metrics

Each AI session tracks:
- **Execution metrics**: Commands run, git operations, tool uses
- **Interaction metrics**: User prompts and inputs
- **Success status**: Exit code and overall success
- **Transcripts**: Both raw and cleaned versions for review
- **Provider metadata**: Which AI assistant and detection method

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

Test the interactive session tracking with different providers:

```bash
# Test Claude tracking
claude-with-tracking "echo 'Hello from Claude'"

# Test Codex tracking
codex-with-tracking "echo 'Hello from Codex'"

# Test GPT tracking
gpt-with-tracking "echo 'Hello from GPT'"

# View the sessions in MLflow UI
open http://localhost:5000
```

## Benefits

1. **Debugging**: Full execution history with errors and artifacts
2. **Performance Monitoring**: Track execution times and success rates
3. **Reproducibility**: Complete record of parameters and environment
4. **Observability**: Visual dashboard for all automation
5. **Career Value**: Industry-standard ML engineering tool experience

## How It Works

1. **Wrapper scripts** (`claude-with-tracking`, `codex-with-tracking`, `gpt-with-tracking`) run AI assistants normally
2. **Session captured** with full interactivity preserved
3. **Parser** (`parse_ai_session.py`) processes provider-specific patterns and extracts metrics
4. **MLflow UI** displays session history and metrics across all providers

**Architecture**: Each `<provider>-with-tracking` wrapper:
- Captures the session using `script` command
- Passes provider info to `parse_ai_session.py`
- Uses provider-specific patterns from `provider_patterns.py`
- Logs to unified MLflow experiment

## Next Steps

- [x] Make tracking provider-agnostic (support Codex, GPT, etc.)
- [ ] Add real-time procedure hooks
- [ ] Implement metric alerts
- [ ] Create custom dashboards
- [ ] Add comparison reports
- [ ] Export metrics to other systems
- [ ] Compare performance across AI providers