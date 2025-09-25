#!/usr/bin/env python3
"""
Parse AI assistant session logs and send metrics to MLflow.

This script analyzes an AI assistant session transcript to extract:
- Commands executed
- Files modified
- Errors encountered
- User interactions
- Timing information

Supports multiple AI providers:
- Claude Code (Anthropic)
- OpenAI Codex
- GPT models
- Generic AI providers
"""

import sys
import json
import re
from pathlib import Path
from datetime import datetime
import argparse
import mlflow
from mlflow import log_metric, log_param, log_text, set_tag

from provider_patterns import get_provider_patterns, detect_provider


def init_mlflow():
    """Initialize MLflow with local tracking."""
    dotfiles_root = Path(__file__).parent.parent
    mlflow.set_tracking_uri(f"file://{dotfiles_root}/mlruns")
    mlflow.set_experiment("ai-sessions")


def parse_session_log(log_path, provider=None):
    """
    Parse an AI assistant session log to extract metrics.

    Args:
        log_path: Path to the session log file
        provider: Optional provider name (claude, codex, gpt, etc.)
                 If not provided, will attempt auto-detection

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

        # Get provider-specific patterns
        patterns = get_provider_patterns(provider, content)

        # Remove ANSI color codes and control characters for cleaner parsing
        ansi_escape = re.compile(patterns['ansi_escape'])
        clean_content = ansi_escape.sub('', content)

        # Also remove other control characters
        clean_content = re.sub(patterns['control_chars'], '', clean_content)

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

        # Parse using provider-specific patterns

        # Bash commands actually executed
        bash_commands = re.findall(patterns['bash_command'], clean_content)
        metrics["commands_executed"] = len(bash_commands)

        # Git operations from actual Bash executions
        git_ops = re.findall(patterns['git_command'], clean_content)
        metrics["git_operations"] = len(git_ops)

        # All tool uses
        tool_uses = re.findall(patterns['tool_pattern'], clean_content)
        metrics["tool_uses"] = len(tool_uses)

        # User interactions
        user_inputs = re.findall(patterns['user_input'], clean_content, re.MULTILINE)
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

    return metrics, events, content, patterns.get('name', 'Unknown Provider')


def log_session_to_mlflow(session_log, metadata_file, exit_code, provider=None):
    """
    Log an AI assistant session to MLflow.

    Args:
        session_log: Path to session log file
        metadata_file: Path to metadata JSON file
        exit_code: Exit code from the session
        provider: Optional provider name (claude, codex, gpt, etc.)
    """
    init_mlflow()

    # Load metadata
    metadata = {}
    if Path(metadata_file).exists():
        with open(metadata_file, "r") as f:
            metadata = json.load(f)

    # Parse session with provider detection
    metrics, events, full_content, provider_name = parse_session_log(session_log, provider)

    # Create MLflow run
    with mlflow.start_run(run_name=metadata.get("session_id", "ai_session")):
        # Log metadata as parameters
        for key, value in metadata.items():
            if value and key != "session_id":
                log_param(key, str(value)[:250])  # MLflow param limit

        # Log provider information
        log_param("ai_provider", provider_name)
        if provider:
            log_param("provider_specified", "true")
        else:
            log_param("provider_specified", "false")

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
        summary = f"""AI Assistant Session Summary
==========================
Session ID: {metadata.get('session_id', 'unknown')}
AI Provider: {provider_name}
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
        set_tag("type", "ai_session")
        set_tag("provider", provider_name.lower().replace(' ', '_'))
        set_tag("interactive", "true")
        set_tag("status", "success" if exit_code == 0 else "failed")

        print(f"✓ Session logged to MLflow (Provider: {provider_name})")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Parse AI assistant session logs for MLflow tracking')
    parser.add_argument('session_log', help='Path to session log file')
    parser.add_argument('metadata_file', help='Path to metadata JSON file')
    parser.add_argument('exit_code', nargs='?', type=int, default=0, help='Exit code from session')
    parser.add_argument('--provider', choices=['claude', 'codex', 'gpt', 'generic'],
                       help='AI provider (auto-detect if not specified)')

    args = parser.parse_args()

    log_session_to_mlflow(args.session_log, args.metadata_file, args.exit_code, args.provider)


if __name__ == "__main__":
    main()