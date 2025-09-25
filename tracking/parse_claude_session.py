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
        "files_modified": 0,
        "files_created": 0,
        "files_read": 0,
        "git_operations": 0,
        "errors_encountered": 0,
        "user_interactions": 0,
        "plan_mode_activations": 0,
        "tool_uses": 0,
    }

    events = []

    try:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        # Remove ANSI color codes for cleaner parsing
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        clean_content = ansi_escape.sub('', content)

        # Parse for various patterns

        # Commands executed (bash, git, etc.)
        bash_commands = re.findall(r'Bash(?:.*?)command["\s:]+([^"]+)', clean_content)
        metrics["commands_executed"] = len(bash_commands)

        # File operations
        files_created = re.findall(r'File created successfully at: (.+)', clean_content)
        metrics["files_created"] = len(files_created)

        files_modified = re.findall(r'The file (.+) has been updated', clean_content)
        metrics["files_modified"] = len(files_modified)

        files_read = re.findall(r'Reading file: (.+)', clean_content)
        metrics["files_read"] = len(files_read)

        # Git operations
        git_ops = re.findall(r'git (?:add|commit|push|pull|checkout|branch)', clean_content, re.IGNORECASE)
        metrics["git_operations"] = len(git_ops)

        # Errors
        errors = re.findall(r'(?:Error|error|ERROR|Failed|failed)[:.](.{0,100})', clean_content)
        metrics["errors_encountered"] = len(errors)

        # Plan mode
        plan_mode = re.findall(r'Plan mode.*active|Entering plan mode|ExitPlanMode', clean_content)
        metrics["plan_mode_activations"] = len(plan_mode)

        # Tool uses (Claude's tool invocations)
        tool_uses = re.findall(r'<function_calls>|Tool ran|Using tool:', clean_content)
        metrics["tool_uses"] = len(tool_uses)

        # User interactions (when user types input)
        user_inputs = re.findall(r'Human:|User:|^[>$] ', clean_content, re.MULTILINE)
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

        # Log the full session transcript as artifact
        log_text(full_content, "session_transcript.txt")

        # Log summary statistics
        summary = f"""Claude Session Summary
=====================
Session ID: {metadata.get('session_id', 'unknown')}
Command: {metadata.get('command', 'unknown')}
Exit Code: {exit_code}

Metrics:
- Commands Executed: {metrics['commands_executed']}
- Files Modified: {metrics['files_modified']}
- Files Created: {metrics['files_created']}
- Git Operations: {metrics['git_operations']}
- Errors: {metrics['errors_encountered']}
- User Interactions: {metrics['user_interactions']}
- Tool Uses: {metrics['tool_uses']}

Events: {', '.join(events)}
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