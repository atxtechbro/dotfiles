#!/usr/bin/env python3
"""
Secure version of update-readme-memory.py for self-hosted runners.
Suppresses potentially sensitive output when running in CI.
"""

import subprocess
import json
import re
import os
import sys
from datetime import datetime, timedelta
from collections import defaultdict, Counter
from pathlib import Path

# Detect if running in CI
IS_CI = os.environ.get('CI', '').lower() == 'true'
IS_GITHUB_ACTIONS = os.environ.get('GITHUB_ACTIONS', '').lower() == 'true'

def secure_print(message, sensitive=False):
    """Print only if not in CI or if not sensitive."""
    if not IS_CI or not sensitive:
        print(message)

def run_git_command(cmd):
    """Run a git command and return output."""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        # Don't print the actual command in CI (might contain paths)
        if IS_CI:
            secure_print(f"Error running git command")
        else:
            secure_print(f"Error running command: {cmd}")
            secure_print(f"Error: {result.stderr}")
        return None
    return result.stdout.strip()

def get_recent_commits(days=7):
    """Get commits from the last N days."""
    since_date = (datetime.now() - timedelta(days=days)).strftime('%Y-%m-%d')
    cmd = f"git log --since='{since_date}' --pretty=format:'%H|%an|%ae|%ad|%s' --date=iso"
    output = run_git_command(cmd)
    if not output:
        return []
    
    commits = []
    for line in output.split('\n'):
        if line:
            parts = line.split('|', 4)
            if len(parts) == 5:
                # In CI, don't include email addresses
                commits.append({
                    'hash': parts[0][:8] if IS_CI else parts[0],  # Shorter hash in CI
                    'author': parts[1],
                    'email': 'hidden' if IS_CI else parts[2],
                    'date': parts[3],
                    'message': parts[4]
                })
    return commits

def get_changed_files(days=7):
    """Get all files changed in the last N days with change counts."""
    since_date = (datetime.now() - timedelta(days=days)).strftime('%Y-%m-%d')
    cmd = f"git log --since='{since_date}' --pretty=format: --name-only | sort | uniq -c | sort -rn"
    output = run_git_command(cmd)
    if not output:
        return []
    
    files = []
    for line in output.split('\n'):
        if line.strip():
            match = re.match(r'\s*(\d+)\s+(.+)', line.strip())
            if match:
                count, filepath = match.groups()
                # Only include relative paths, no absolute paths
                if not filepath.startswith('/'):
                    files.append((int(count), filepath))
    return files

def analyze_commit_patterns(commits):
    """Analyze patterns in commit messages."""
    commit_types = Counter()
    scopes = Counter()
    principles = Counter()
    
    for commit in commits:
        msg = commit['message']
        
        # Match conventional commit format
        match = re.match(r'^(\w+)(?:\[([^\]]+)\])?:', msg)
        if match:
            commit_type = match.group(1)
            scope = match.group(2)
            commit_types[commit_type] += 1
            if scope:
                scopes[scope] += 1
        
        # Look for principle trailers
        principle_match = re.search(r'Principle:\s*(\S+)', msg)
        if principle_match:
            principles[principle_match.group(1)] += 1
    
    return {
        'types': commit_types.most_common(5),
        'scopes': scopes.most_common(5),
        'principles': principles.most_common(3)
    }

def generate_memory_section(days=7):
    """Generate the memory context section."""
    commits = get_recent_commits(days)
    if not commits:
        return None
    
    files = get_changed_files(days)
    patterns = analyze_commit_patterns(commits)
    
    # Build the memory section
    section = []
    section.append(f"\n## 🧠 Recent Activity Context (Last {days} Days)")
    section.append(f"\n*Auto-generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - helps Claude remember recent work*")
    
    # Activity summary
    section.append(f"\n### Activity Summary")
    section.append(f"- **Total Commits**: {len(commits)}")
    section.append(f"- **Files Modified**: {len(files)}")
    
    # Most active areas - limit output in CI
    max_files = 5 if IS_CI else 10
    if files[:max_files]:
        section.append(f"\n### Most Active Files")
        for count, filepath in files[:max_files]:
            section.append(f"- `{filepath}` ({count} changes)")
    
    # Commit patterns
    if patterns['types']:
        section.append(f"\n### Recent Work Types")
        for commit_type, count in patterns['types']:
            section.append(f"- **{commit_type}**: {count} commits")
    
    if patterns['scopes']:
        section.append(f"\n### Active Components")
        for scope, count in patterns['scopes']:
            section.append(f"- **{scope}**: {count} commits")
    
    if patterns['principles']:
        section.append(f"\n### Applied Principles")
        for principle, count in patterns['principles']:
            section.append(f"- `{principle}`: {count} times")
    
    # Recent feature work - limit in CI
    section.append(f"\n### Recent Feature Work")
    feature_commits = [c for c in commits if c['message'].startswith(('feat', 'feature'))][:3 if IS_CI else 5]
    if feature_commits:
        for commit in feature_commits:
            date = datetime.fromisoformat(commit['date'].replace(' ', 'T').split('+')[0])
            section.append(f"- {date.strftime('%m/%d')}: {commit['message']}")
    else:
        section.append("- No recent feature commits")
    
    # Current areas of focus
    section.append(f"\n### Current Focus Areas")
    focus_areas = defaultdict(int)
    for count, filepath in files:
        if filepath.startswith('mcp/'):
            focus_areas['MCP Servers'] += count
        elif filepath.startswith('utils/'):
            focus_areas['Utilities'] += count
        elif filepath.startswith('.bashrc') or filepath.startswith('.bash'):
            focus_areas['Shell Configuration'] += count
        elif filepath.startswith('knowledge/'):
            focus_areas['Knowledge Base'] += count
    
    for area, count in sorted(focus_areas.items(), key=lambda x: x[1], reverse=True)[:3]:
        section.append(f"- **{area}**: {count} changes")
    
    return '\n'.join(section)

def update_readme(memory_section):
    """Update README.md with the memory section."""
    readme_path = Path(__file__).parent.parent / 'README.md'
    
    if not readme_path.exists():
        secure_print(f"README.md not found", sensitive=True)
        return False
    
    content = readme_path.read_text()
    
    # Find where to insert/update the memory section
    memory_pattern = r'\n## 🧠 Recent Activity Context.*?(?=\n## |\Z)'
    
    if re.search(memory_pattern, content, re.DOTALL):
        # Replace existing section
        new_content = re.sub(memory_pattern, memory_section, content, flags=re.DOTALL)
    else:
        # Insert after the philosophy section
        insert_pattern = r'(This principle ensures that our development environment continuously improves over time\.)'
        new_content = re.sub(insert_pattern, r'\1' + memory_section, content)
    
    readme_path.write_text(new_content)
    return True

def main():
    """Main function."""
    days = 7
    if len(sys.argv) > 1:
        try:
            days = int(sys.argv[1])
        except ValueError:
            secure_print(f"Invalid days argument")
            sys.exit(1)
    
    secure_print(f"Analyzing git activity from the last {days} days...")
    memory_section = generate_memory_section(days)
    
    if not memory_section:
        secure_print("No recent git activity found.")
        sys.exit(0)
    
    # Only show generated section if not in CI
    if not IS_CI:
        secure_print("Generated memory section:")
        secure_print(memory_section)
    else:
        secure_print("Memory section generated successfully")
    
    if update_readme(memory_section):
        secure_print("Successfully updated README.md")
    else:
        secure_print("Failed to update README.md")
        sys.exit(1)

if __name__ == "__main__":
    main()