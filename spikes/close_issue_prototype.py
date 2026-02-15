#!/usr/bin/env python3
"""
Prototype: Platform-Aware /close-issue Command Integration

This demonstrates how the /close-issue command could detect the platform
and route to the appropriate MCP tools.
"""

import re
from typing import Dict, Any, Optional
from git_remote_detection import detect_git_platform


class CloseIssueCommand:
    """Prototype for platform-aware close-issue command."""
    
    def __init__(self):
        self.github_tools = {
            "get_issue": "mcp__github-read__get_issue",
            "add_comment": "mcp__github-write__add_issue_comment",
            "update_issue": "mcp__github-write__update_issue",
            "close_issue": "mcp__github-write__update_issue"  # state: closed
        }
        
        self.gitlab_tools = {
            "get_issue": "gitlab_get_issue",
            "add_comment": "gitlab_create_issue_comment", 
            "update_issue": "gitlab_update_issue",
            "close_issue": "gitlab_close_issue"
        }
    
    def parse_issue_arg(self, arg: str) -> tuple[Optional[str], Optional[int], Optional[str], Optional[str]]:
        """
        Parse issue argument to extract platform, owner, repo, and issue number.
        
        Supports:
        - Just number: 123
        - GitHub URL: https://github.com/owner/repo/issues/123
        - GitLab URL: https://gitlab.com/owner/project/-/issues/123
        
        Returns: (platform, issue_number, owner, repo)
        """
        # Just a number - use git detection
        if arg.isdigit():
            return None, int(arg), None, None
        
        # GitHub URL pattern
        github_pattern = r'https://github\.com/([^/]+)/([^/]+)/issues/(\d+)'
        github_match = re.match(github_pattern, arg)
        if github_match:
            return 'github', int(github_match.group(3)), github_match.group(1), github_match.group(2)
        
        # GitLab URL pattern (note the /-/ in the path)
        gitlab_pattern = r'https://gitlab\.com/([^/]+(?:/[^/]+)*)/([^/]+)/-/issues/(\d+)'
        gitlab_match = re.match(gitlab_pattern, arg)
        if gitlab_match:
            return 'gitlab', int(gitlab_match.group(3)), gitlab_match.group(1), gitlab_match.group(2)
        
        # Self-hosted GitLab pattern
        gitlab_selfhosted_pattern = r'https://([^/]+)/([^/]+(?:/[^/]+)*)/([^/]+)/-/issues/(\d+)'
        gitlab_selfhosted_match = re.match(gitlab_selfhosted_pattern, arg)
        if gitlab_selfhosted_match and 'gitlab' in gitlab_selfhosted_match.group(1):
            return 'gitlab', int(gitlab_selfhosted_match.group(4)), gitlab_selfhosted_match.group(2), gitlab_selfhosted_match.group(3)
        
        return None, None, None, None
    
    def get_platform_tools(self, platform: str) -> Dict[str, str]:
        """Get the appropriate MCP tools for the platform."""
        if platform == 'gitlab':
            return self.gitlab_tools
        else:
            # Default to GitHub
            return self.github_tools
    
    def execute(self, issue_arg: str, additional_prompt: Optional[str] = None):
        """Execute the close-issue command."""
        # Parse the issue argument
        url_platform, issue_number, owner, repo = self.parse_issue_arg(issue_arg)
        
        # If platform not detected from URL, use git detection
        if not url_platform:
            git_info = detect_git_platform()
            platform = git_info['platform'] or 'github'
            
            # Use git-detected owner/repo if not provided
            if not owner:
                owner = git_info['owner']
            if not repo:
                repo = git_info['repo']
        else:
            platform = url_platform
        
        # Get appropriate tools
        tools = self.get_platform_tools(platform)
        
        print(f"\n=== Close Issue Command Execution Plan ===")
        print(f"Platform: {platform}")
        print(f"Issue: #{issue_number}")
        print(f"Repository: {owner}/{repo}")
        if additional_prompt:
            print(f"Additional context: {additional_prompt}")
        print(f"\nMCP Tools to use:")
        print(f"1. Fetch issue: {tools['get_issue']}")
        print(f"2. Add comment: {tools['add_comment']}")
        print(f"3. Close issue: {tools['close_issue']}")
        
        # Simulate the workflow
        print(f"\n=== Simulated Workflow ===")
        print(f"1. Call {tools['get_issue']} with:")
        print(f"   - {'project' if platform == 'gitlab' else 'owner'}: {owner}")
        print(f"   - {'issue_id' if platform == 'gitlab' else 'repo'}: {repo if platform == 'github' else issue_number}")
        if platform == 'github':
            print(f"   - issue_number: {issue_number}")
        
        print(f"\n2. Implement solution based on issue details...")
        if additional_prompt:
            print(f"   (Considering user guidance: {additional_prompt})")
        
        print(f"\n3. Create PR and link to issue...")
        
        print(f"\n4. Call {tools['close_issue']} to close the issue")


def main():
    """Test the platform-aware close-issue command."""
    cmd = CloseIssueCommand()
    
    # Test cases
    test_cases = [
        ("123", None),
        ("123", "focus on performance optimization"),
        ("https://github.com/owner/repo/issues/456", None),
        ("https://gitlab.com/group/project/-/issues/789", None),
        ("https://gitlab.com/group/subgroup/project/-/issues/100", "use new MCP tools"),
    ]
    
    for issue_arg, prompt in test_cases:
        print("\n" + "="*60)
        print(f"Test: /close-issue {issue_arg}" + (f' "{prompt}"' if prompt else ""))
        cmd.execute(issue_arg, prompt)


if __name__ == "__main__":
    main()