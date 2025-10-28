#!/usr/bin/env python3
"""
Parse AI assistant session logs and send metrics to MLflow.

This script analyzes AI assistant session transcripts to extract:
- Commands executed (bash, git, gh, etc.)
- Files modified
- Errors encountered
- User interactions
- Timing information

Provider-agnostic: Works with any AI assistant by looking for actual
commands in the output rather than provider-specific formatting.
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
    mlflow.set_tracking_uri(f"file://{dotfiles_root}/claude-runs")
    mlflow.set_experiment("claude-sessions")


def parse_session_log(log_path):
    """
    Parse an AI assistant session log to extract metrics.

    Provider-agnostic approach: Looks for actual commands and operations
    in the transcript regardless of AI provider formatting.

    Returns dict with extracted metrics and events.
    """
    metrics = {
        "commands_executed": 0,
        "git_operations": 0,
        "user_interactions": 0,
    }

    events = []
    clean_content = ""

    try:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        # Remove ANSI color codes and control characters for cleaner parsing
        # This comprehensive pattern matches all ANSI escape sequences
        ansi_escape = re.compile(r'''
            \x1B  # ESC
            (?:   # 7-bit C1 Fe (except CSI)
                [@-Z\\-_]
            |     # or [ for CSI, followed by a control sequence
                \[
                [0-?]*  # Parameter bytes
                [ -/]*  # Intermediate bytes
                [@-~]   # Final byte
            )
        ''', re.VERBOSE)
        clean_content = ansi_escape.sub('', content)

        # Remove CSI sequences that don't start with ESC (direct bracket sequences)
        clean_content = re.sub(r'\[[0-9;?]*[a-zA-Z]', '', clean_content)

        # Remove OSC sequences (Operating System Commands)
        clean_content = re.sub(r'\][0-9];[^\x07\x1b]*[\x07\x1b\\]', '', clean_content)

        # Remove terminal control sequences that use different formats
        # Remove sequences like ]>7u]en which are terminal responses
        clean_content = re.sub(r'\][>0-9]+[a-z]+', '', clean_content)
        clean_content = re.sub(r'\[[\?!][0-9]+[hlc]', '', clean_content)
        # Remove remaining ]text patterns at start of lines
        clean_content = re.sub(r'^\][a-z]+', '', clean_content, flags=re.MULTILINE)

        # Also remove other control characters (but keep newlines and tabs)
        clean_content = re.sub(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]', '', clean_content)

        # Remove script/typescript headers if present (do this before removing brackets)
        clean_content = re.sub(r'Script started on .+?\[COMMAND=.*?\]\n?', '', clean_content)
        clean_content = re.sub(r'^Script done on .+?\n', '', clean_content, flags=re.MULTILINE)

        # Remove excessive padding characters (═ sequences)
        # These appear between character-by-character updates
        clean_content = re.sub(r'═{10,}', '═' * 10, clean_content)  # Cap at 10
        clean_content = re.sub(r'(═{5,}\n){2,}', '═════\n', clean_content)  # Collapse multiple padding lines

        # Enhanced deduplication: Remove progressive typing snapshots
        lines = clean_content.split('\n')
        unique_lines = []
        prev_stripped = None

        for i, line in enumerate(lines):
            stripped = line.strip()

            # Skip empty lines that are just padding
            if not stripped or stripped == '═' * len(stripped):
                # Only keep one padding line between content
                if unique_lines and not unique_lines[-1].strip():
                    continue
                if stripped == '═' * len(stripped) and len(unique_lines) > 0:
                    continue

            # Skip if this line is a prefix of the next line (progressive typing)
            if i < len(lines) - 1:
                next_stripped = lines[i + 1].strip()
                if next_stripped and stripped and next_stripped.startswith(stripped):
                    # This is an incomplete version of the next line, skip it
                    continue

            # Skip if this line is the same as the previous (exact duplicates)
            if stripped and stripped == prev_stripped:
                continue

            unique_lines.append(line)
            prev_stripped = stripped

        # Second pass: Remove lines that look like incomplete typing
        # Pattern: >• [partial text] where the next occurrence has more text
        final_lines = []
        i = 0
        while i < len(unique_lines):
            line = unique_lines[i]

            # Check if this looks like a prompt with partial input
            prompt_match = re.match(r'^(>•?\s*|\$\s*|>>>\s*)(.*)$', line.strip())
            if prompt_match and i < len(unique_lines) - 1:
                prompt_prefix = prompt_match.group(1)
                current_text = prompt_match.group(2)

                # Look ahead for more complete versions
                j = i + 1
                most_complete = line
                most_complete_text = current_text
                skip_to = i + 1

                while j < len(unique_lines) and j < i + 20:  # Check next 20 lines max
                    next_line = unique_lines[j]
                    next_match = re.match(r'^' + re.escape(prompt_prefix) + r'(.*)$', next_line.strip())

                    if next_match:
                        next_text = next_match.group(1)
                        # If the next one is longer and starts with current, it's more complete
                        if len(next_text) > len(most_complete_text) and next_text.startswith(most_complete_text):
                            most_complete = next_line
                            most_complete_text = next_text
                            skip_to = j + 1  # Skip past this one
                        elif next_text == most_complete_text:
                            # Same command repeated, skip it
                            skip_to = j + 1
                        elif not next_text.startswith(current_text[:min(len(current_text), 3)]):
                            # Different command (doesn't start with same prefix), stop looking
                            break
                    j += 1

                # Add the most complete version and skip intermediates
                final_lines.append(most_complete)
                i = skip_to
            else:
                final_lines.append(line)
                i += 1

        clean_content = '\n'.join(final_lines)

        # Provider-agnostic parsing: Look for actual commands regardless of formatting

        # Find bash/shell commands (common patterns across providers)
        # Look for lines that appear to be shell commands
        bash_patterns = [
            r'(?:^|\n)\$ .+',  # Shell prompt format
            r'(?:bash|Bash|BASH)[:\(\[].*?[\)\]\n]',  # Various bash invocation formats
            r'(?:>>>|●) (?:bash|Bash).*',  # Common AI tool formats
            r'(?:execute|run|command):\s*.+',  # Command descriptions
        ]
        bash_commands = []
        for pattern in bash_patterns:
            bash_commands.extend(re.findall(pattern, clean_content, re.IGNORECASE))
        metrics["commands_executed"] = len(set(bash_commands))  # Dedupe

        # Git operations (look for actual git commands)
        git_patterns = [
            r'git (?:clone|add|commit|push|pull|checkout|branch|merge|rebase|status|log|diff)',
            r'gh (?:pr|issue|repo|workflow|api)',  # GitHub CLI commands
        ]
        git_ops = []
        for pattern in git_patterns:
            git_ops.extend(re.findall(pattern, clean_content, re.IGNORECASE))
        metrics["git_operations"] = len(git_ops)

        # User interactions (various prompt formats)
        user_patterns = [
            r'^> .+',  # Claude format
            r'^(?:User|Human|You):\s*.+',  # Common chat formats
            r'^\[USER\]\s*.+',  # Bracketed format
        ]
        user_inputs = []
        for pattern in user_patterns:
            user_inputs.extend(re.findall(pattern, clean_content, re.MULTILINE | re.IGNORECASE))
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

    return metrics, events, clean_content


def log_session_to_mlflow(session_log, metadata_file, exit_code):
    """
    Log an AI assistant session to MLflow.
    """
    init_mlflow()

    # Load metadata
    metadata = {}
    if Path(metadata_file).exists():
        with open(metadata_file, "r") as f:
            metadata = json.load(f)

    # Parse session
    metrics, events, clean_content = parse_session_log(session_log)

    # Also load the raw content for comparison
    try:
        with open(session_log, "r", encoding="utf-8", errors="ignore") as f:
            raw_content = f.read()
    except:
        raw_content = clean_content

    # Create MLflow run
    with mlflow.start_run(run_name=metadata.get("session_id", "ai_session")):
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

        # Log cleaned transcript as main artifact (this is what users see)
        log_text(clean_content, "session_transcript.txt")
        # Also keep raw for debugging if needed
        log_text(raw_content, "session_transcript_raw.txt")

        # Log summary statistics
        summary = f"""AI Assistant Session Summary
==========================
Session ID: {metadata.get('session_id', 'unknown')}
Command: {metadata.get('command', 'unknown')}
Exit Code: {exit_code}

Metrics:
- Commands Executed: {metrics['commands_executed']}
- Git Operations: {metrics['git_operations']}
- User Interactions: {metrics['user_interactions']}

Events: {', '.join(events) if events else 'None'}
"""
        log_text(summary, "session_summary.txt")

        # Set overall tags
        set_tag("type", "ai_session")
        set_tag("interactive", "true")
        set_tag("status", "success" if exit_code == 0 else "failed")

        # If provider info is in metadata, log it
        if "ai_provider" in metadata:
            set_tag("provider", metadata["ai_provider"])

        print(f"✓ Session logged to MLflow")


def main():
    """Main entry point."""
    if len(sys.argv) < 3:
        print("Usage: parse_session.py <session_log> <metadata_file> [exit_code]")
        sys.exit(1)

    session_log = sys.argv[1]
    metadata_file = sys.argv[2]
    exit_code = int(sys.argv[3]) if len(sys.argv) > 3 else 0

    log_session_to_mlflow(session_log, metadata_file, exit_code)


if __name__ == "__main__":
    main()