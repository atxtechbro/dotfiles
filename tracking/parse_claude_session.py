#!/usr/bin/env python3
"""
Parse Claude CLI session logs and send metrics to MLflow.

This script analyzes a Claude session transcript to extract:
- Commands executed
- Files modified
- Errors encountered
- User interactions
- Timing information
"""

import sys
import json
import re
from pathlib import Path
from datetime import datetime
import mlflow
from mlflow import log_metric, log_param, log_text, set_tag


def init_mlflow():
    """Initialize MLflow with local tracking."""
    dotfiles_root = Path(__file__).parent.parent
    mlflow.set_tracking_uri(f"file://{dotfiles_root}/mlruns")
    mlflow.set_experiment("claude-sessions")


def parse_session_log(log_path):
    """
    Parse a Claude session log to extract metrics.

    Returns dict with extracted metrics and events.
    """
    metrics = {
        "commands_executed": 0,
        "git_operations": 0,
        "tool_uses": 0,
        "user_interactions": 0,
    }

    events = []
    clean_content = ""

    try:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        # Remove ANSI color codes and control characters for cleaner parsing
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        clean_content = ansi_escape.sub('', content)

        # Also remove other control characters
        clean_content = re.sub(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]', '', clean_content)

        # Remove duplicate consecutive lines (from terminal redraws)
        lines = clean_content.split('\n')
        unique_lines = []
        prev_line = None
        for line in lines:
            stripped = line.strip()
            if stripped and stripped != prev_line:
                unique_lines.append(line)
                prev_line = stripped
        clean_content = '\n'.join(unique_lines)

        # Parse for Claude's actual tool use patterns (● ToolName(...))

        # Bash commands actually executed
        bash_commands = re.findall(r'● Bash\([^)]+\)', clean_content)
        metrics["commands_executed"] = len(bash_commands)

        # Git operations from actual Bash executions
        git_ops = re.findall(r'● Bash\([^)]*\bgit\b[^)]*\)', clean_content)
        metrics["git_operations"] = len(git_ops)

        # All tool uses (Bash, Read, Task, Update, etc.)
        tool_uses = re.findall(r'● (?:Bash|Read|Task|Update|Write|Edit|MultiEdit|Grep|Glob)\([^)]*\)', clean_content)
        metrics["tool_uses"] = len(tool_uses)

        # User interactions (prompts starting with >)
        user_inputs = re.findall(r'^> .+', clean_content, re.MULTILINE)
        metrics["user_interactions"] = len(user_inputs)

        # Key events for timeline
        if "close-issue" in clean_content.lower():
            events.append("close_issue_procedure")
        if "extract-best-frame" in clean_content.lower():
            events.append("extract_best_frame_procedure")
        if "pull request created" in clean_content.lower():
            events.append("pr_created")
        if "commit" in clean_content.lower():
            events.append("commit_made")

    except Exception as e:
        print(f"Error parsing log: {e}")

    return metrics, events, content


def log_session_to_mlflow(session_log, metadata_file, exit_code):
    """
    Log a Claude session to MLflow.
    """
    init_mlflow()

    # Load metadata
    metadata = {}
    if Path(metadata_file).exists():
        with open(metadata_file, "r") as f:
            metadata = json.load(f)

    # Parse session
    metrics, events, full_content = parse_session_log(session_log)

    # Create MLflow run
    with mlflow.start_run(run_name=metadata.get("session_id", "claude_session")):
        # Log metadata as parameters
        for key, value in metadata.items():
            if value and key != "session_id":
                log_param(key, str(value)[:250])  # MLflow param limit

        # Log metrics
        for metric_name, value in metrics.items():
            log_metric(metric_name, value)

        # Log session outcome
        log_metric("exit_code", exit_code)
        log_metric("success", 1 if exit_code == 0 else 0)

        # Calculate and log duration
        if "start_time" in metadata:
            try:
                start = datetime.fromisoformat(metadata["start_time"])
                duration = (datetime.now() - start).total_seconds()
                log_metric("duration_seconds", duration)
            except:
                pass

        # Log events as tags
        for event in events[:10]:  # MLflow has tag limits
            set_tag(f"event_{events.index(event)}", event)

        # Log both raw and cleaned transcripts as artifacts
        log_text(full_content, "session_transcript_raw.txt")
        log_text(clean_content, "session_transcript_clean.txt")

        # Log summary statistics
        summary = f"""Claude Session Summary
=====================
Session ID: {metadata.get('session_id', 'unknown')}
Command: {metadata.get('command', 'unknown')}
Exit Code: {exit_code}

Metrics:
- Commands Executed: {metrics['commands_executed']}
- Git Operations: {metrics['git_operations']}
- Tool Uses: {metrics['tool_uses']}
- User Interactions: {metrics['user_interactions']}

Events: {', '.join(events) if events else 'None'}
"""
        log_text(summary, "session_summary.txt")

        # Set overall tags
        set_tag("type", "claude_session")
        set_tag("interactive", "true")
        set_tag("status", "success" if exit_code == 0 else "failed")

        print(f"✓ Session logged to MLflow")


def main():
    """Main entry point."""
    if len(sys.argv) < 3:
        print("Usage: parse_claude_session.py <session_log> <metadata_file> [exit_code]")
        sys.exit(1)

    session_log = sys.argv[1]
    metadata_file = sys.argv[2]
    exit_code = int(sys.argv[3]) if len(sys.argv) > 3 else 0

    log_session_to_mlflow(session_log, metadata_file, exit_code)


if __name__ == "__main__":
    main()