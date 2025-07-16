#!/usr/bin/env python3
"""
Spike: Git Remote Detection for Platform-Aware /close-issue Command

This prototype demonstrates how to detect the git hosting platform
from the current repository's remote configuration.
"""

import subprocess
import re
from typing import Optional, Tuple
from urllib.parse import urlparse


def get_git_remote_url(remote_name: str = "origin") -> Optional[str]:
    """Get the URL of a git remote."""
    try:
        result = subprocess.run(
            ["git", "remote", "get-url", remote_name],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None


def parse_git_url(url: str) -> Tuple[Optional[str], Optional[str], Optional[str]]:
    """
    Parse a git URL to extract platform, owner, and repo.
    
    Handles both SSH and HTTPS formats:
    - git@github.com:owner/repo.git
    - https://github.com/owner/repo.git
    - git@gitlab.com:owner/project.git
    - https://gitlab.company.com/group/subgroup/project.git
    """
    # SSH format: git@host:path.git
    ssh_pattern = r'^git@([^:]+):(.+?)(?:\.git)?$'
    ssh_match = re.match(ssh_pattern, url)
    
    if ssh_match:
        host = ssh_match.group(1)
        path = ssh_match.group(2)
    else:
        # HTTPS format
        parsed = urlparse(url)
        host = parsed.netloc
        path = parsed.path.strip('/')
        if path.endswith('.git'):
            path = path[:-4]
    
    # Detect platform from host
    platform = None
    if 'github.com' in host:
        platform = 'github'
    elif 'gitlab' in host:
        platform = 'gitlab'
    elif 'bitbucket' in host:
        platform = 'bitbucket'
    else:
        # Could be self-hosted GitLab or other platform
        # Check for common GitLab indicators in the URL structure
        if '/gitlab/' in url or host.startswith('gitlab.'):
            platform = 'gitlab'
    
    # Extract owner and repo from path
    path_parts = path.split('/')
    if len(path_parts) >= 2:
        # For GitLab, might have group/subgroup/project structure
        if platform == 'gitlab' and len(path_parts) > 2:
            owner = '/'.join(path_parts[:-1])
            repo = path_parts[-1]
        else:
            owner = path_parts[0]
            repo = path_parts[1]
    else:
        owner = None
        repo = None
    
    return platform, owner, repo


def detect_git_platform() -> dict:
    """
    Detect the git platform from the current repository.
    
    Returns a dict with:
    - platform: 'github', 'gitlab', 'bitbucket', or None
    - owner: repository owner/organization
    - repo: repository name
    - remote_url: full remote URL
    - error: error message if detection failed
    """
    # Try to get origin remote
    remote_url = get_git_remote_url("origin")
    
    if not remote_url:
        # Try upstream or other common remotes
        for remote in ["upstream", "gitlab", "github"]:
            remote_url = get_git_remote_url(remote)
            if remote_url:
                break
    
    if not remote_url:
        return {
            "platform": None,
            "owner": None,
            "repo": None,
            "remote_url": None,
            "error": "No git remote found"
        }
    
    platform, owner, repo = parse_git_url(remote_url)
    
    return {
        "platform": platform,
        "owner": owner,
        "repo": repo,
        "remote_url": remote_url,
        "error": None if platform else "Unknown git platform"
    }


def main():
    """Test the git platform detection."""
    result = detect_git_platform()
    
    print("Git Platform Detection Results:")
    print("-" * 40)
    print(f"Platform: {result['platform'] or 'Unknown'}")
    print(f"Owner: {result['owner'] or 'N/A'}")
    print(f"Repository: {result['repo'] or 'N/A'}")
    print(f"Remote URL: {result['remote_url'] or 'N/A'}")
    
    if result['error']:
        print(f"Error: {result['error']}")
    
    print("\nRecommendation for /close-issue command:")
    if result['platform'] == 'github':
        print("✓ Use existing GitHub MCP tools")
    elif result['platform'] == 'gitlab':
        print("✓ Use GitLab MCP tools (already available!)")
    else:
        print("⚠ Platform not supported, fall back to GitHub")


if __name__ == "__main__":
    main()