import logging
from enum import Enum
from pathlib import Path
from typing import Sequence

import git
from pydantic import BaseModel

from mcp.server import Server
from mcp.server.session import ServerSession
from mcp.server.stdio import stdio_server
from mcp.types import (
    ClientCapabilities,
    ListRootsResult,
    RootsCapability,
    TextContent,
    Tool,
    Prompt,
    PromptArgument,
    PromptMessage,
    GetPromptResult,
)

from .logging_utils import log_tool_error, log_tool_success

class GitStatus(BaseModel):
    repo_path: str

class GitDiffUnstaged(BaseModel):
    repo_path: str

class GitDiffStaged(BaseModel):
    repo_path: str

class GitDiff(BaseModel):
    repo_path: str
    target: str

class GitCommit(BaseModel):
    repo_path: str
    message: str

class GitAdd(BaseModel):
    repo_path: str
    files: list[str]

class GitReset(BaseModel):
    repo_path: str

class GitLog(BaseModel):
    repo_path: str
    max_count: int = 10

class GitCreateBranch(BaseModel):
    repo_path: str
    branch_name: str
    base_branch: str | None = None

class GitCheckout(BaseModel):
    repo_path: str
    branch_name: str

class GitShow(BaseModel):
    repo_path: str
    revision: str

class GitWorktreeAdd(BaseModel):
    repo_path: str
    worktree_path: str
    branch_name: str | None = None
    create_branch: bool = False

class GitWorktreeRemove(BaseModel):
    repo_path: str
    worktree_path: str
    force: bool = False

class GitWorktreeList(BaseModel):
    repo_path: str

class GitPush(BaseModel):
    repo_path: str
    remote: str = "origin"
    branch: str | None = None
    set_upstream: bool = False
    force: bool = False

class GitRemote(BaseModel):
    repo_path: str
    action: str  # "list", "add", "remove", "get-url"
    name: str | None = None
    url: str | None = None

class GitTools(str, Enum):
    STATUS = "git_status"
    DIFF_UNSTAGED = "git_diff_unstaged"
    DIFF_STAGED = "git_diff_staged"
    DIFF = "git_diff"
    COMMIT = "git_commit"
    ADD = "git_add"
    RESET = "git_reset"
    LOG = "git_log"
    CREATE_BRANCH = "git_create_branch"
    CHECKOUT = "git_checkout"
    SHOW = "git_show"
    WORKTREE_ADD = "git_worktree_add"
    WORKTREE_REMOVE = "git_worktree_remove"
    WORKTREE_LIST = "git_worktree_list"
    PUSH = "git_push"
    REMOTE = "git_remote"

def git_status(repo: git.Repo) -> str:
    return repo.git.status()

def git_diff_unstaged(repo: git.Repo) -> str:
    return repo.git.diff()

def git_diff_staged(repo: git.Repo) -> str:
    return repo.git.diff("--cached")

def git_diff(repo: git.Repo, target: str) -> str:
    return repo.git.diff(target)

def git_commit(repo: git.Repo, message: str) -> str:
    commit = repo.index.commit(message)
    return f"Changes committed successfully with hash {commit.hexsha}"

def git_add(repo: git.Repo, files: list[str]) -> str:
    repo.index.add(files)
    return "Files staged successfully"

def git_reset(repo: git.Repo) -> str:
    repo.index.reset()
    return "All staged changes reset"

def git_log(repo: git.Repo, max_count: int = 10) -> list[str]:
    commits = list(repo.iter_commits(max_count=max_count))
    log = []
    for commit in commits:
        log.append(
            f"Commit: {commit.hexsha}\n"
            f"Author: {commit.author}\n"
            f"Date: {commit.authored_datetime}\n"
            f"Message: {commit.message}\n"
        )
    return log

def git_create_branch(repo: git.Repo, branch_name: str, base_branch: str | None = None) -> str:
    if base_branch:
        base = repo.refs[base_branch]
    else:
        base = repo.active_branch

    repo.create_head(branch_name, base)
    return f"Created branch '{branch_name}' from '{base.name}'"

def git_checkout(repo: git.Repo, branch_name: str) -> str:
    repo.git.checkout(branch_name)
    return f"Switched to branch '{branch_name}'"

def git_show(repo: git.Repo, revision: str) -> str:
    commit = repo.commit(revision)
    output = [
        f"Commit: {commit.hexsha}\n"
        f"Author: {commit.author}\n"
        f"Date: {commit.authored_datetime}\n"
        f"Message: {commit.message}\n"
    ]
    if commit.parents:
        parent = commit.parents[0]
        diff = parent.diff(commit, create_patch=True)
    else:
        diff = commit.diff(git.NULL_TREE, create_patch=True)
    for d in diff:
        output.append(f"\n--- {d.a_path}\n+++ {d.b_path}\n")
        output.append(d.diff.decode('utf-8'))
    return "".join(output)

def git_worktree_add(repo: git.Repo, worktree_path: str, branch_name: str | None = None, create_branch: bool = False) -> str:
    """Add a new worktree"""
    if create_branch and branch_name:
        output = repo.git.worktree("add", "-b", branch_name, worktree_path)
    elif branch_name:
        output = repo.git.worktree("add", worktree_path, branch_name)
    else:
        output = repo.git.worktree("add", worktree_path)
    
    return f"Worktree added at {worktree_path}" + (f" on new branch {branch_name}" if create_branch else "")

def git_worktree_remove(repo: git.Repo, worktree_path: str, force: bool = False) -> str:
    """Remove a worktree"""
    if force:
        output = repo.git.worktree("remove", "--force", worktree_path)
    else:
        output = repo.git.worktree("remove", worktree_path)
    
    return f"Worktree at {worktree_path} removed"

def git_worktree_list(repo: git.Repo) -> str:
    """List all worktrees"""
    output = repo.git.worktree("list", "--porcelain")
    
    # Parse porcelain output
    worktrees = []
    current_worktree = {}
    
    for line in output.strip().split('\n'):
        if not line:
            if current_worktree:
                worktrees.append(current_worktree)
                current_worktree = {}
        elif line.startswith("worktree "):
            current_worktree["path"] = line[9:]
        elif line.startswith("HEAD "):
            current_worktree["head"] = line[5:]
        elif line.startswith("branch "):
            current_worktree["branch"] = line[7:]
    
    if current_worktree:
        worktrees.append(current_worktree)
    
    # Format output
    result = []
    for wt in worktrees:
        result.append(f"Path: {wt.get('path', 'unknown')}")
        result.append(f"  Branch: {wt.get('branch', 'detached HEAD')}")
        result.append(f"  HEAD: {wt.get('head', 'unknown')[:8]}")
        result.append("")
    
    return "\n".join(result).strip()

def git_push(repo: git.Repo, remote: str = "origin", branch: str | None = None, set_upstream: bool = False, force: bool = False) -> str:
    """Push changes to remote repository"""
    # Build command as a list
    cmd_parts = []
    
    if force:
        cmd_parts.append("--force")
    
    if set_upstream:
        cmd_parts.extend(["-u", remote, branch or repo.active_branch.name])
    else:
        cmd_parts.extend([remote, branch or repo.active_branch.name])
    
    # Use the git command directly through repo.git
    output = repo.git.push(*cmd_parts)
    
    return f"Pushed {branch or repo.active_branch.name} to {remote}" + (f" (tracking)" if set_upstream else "")

def git_remote(repo: git.Repo, action: str, name: str | None = None, url: str | None = None) -> str:
    """Manage remote repositories"""
    if action == "list":
        remotes = repo.git.remote("-v")
        return remotes if remotes else "No remotes configured"
    
    elif action == "add":
        if not name or not url:
            return "Error: Both name and url required for adding remote"
        repo.git.remote("add", name, url)
        return f"Added remote '{name}' -> {url}"
    
    elif action == "remove":
        if not name:
            return "Error: Remote name required for removal"
        repo.git.remote("remove", name)
        return f"Removed remote '{name}'"
    
    elif action == "get-url":
        if not name:
            return "Error: Remote name required"
        url = repo.git.remote("get-url", name)
        return f"{name}: {url}"
    
    else:
        return f"Error: Unknown action '{action}'. Valid actions: list, add, remove, get-url"

async def serve(repository: Path | None) -> None:
    logger = logging.getLogger(__name__)

    if repository is not None:
        try:
            git.Repo(repository)
            logger.info(f"Using repository at {repository}")
        except git.InvalidGitRepositoryError:
            logger.error(f"{repository} is not a valid Git repository")
            return

    server = Server("mcp-git")

    @server.list_tools()
    async def list_tools() -> list[Tool]:
        return [
            Tool(
                name=GitTools.STATUS,
                description="Shows the working tree status",
                inputSchema=GitStatus.schema(),
            ),
            Tool(
                name=GitTools.DIFF_UNSTAGED,
                description="Shows changes in the working directory that are not yet staged",
                inputSchema=GitDiffUnstaged.schema(),
            ),
            Tool(
                name=GitTools.DIFF_STAGED,
                description="Shows changes that are staged for commit",
                inputSchema=GitDiffStaged.schema(),
            ),
            Tool(
                name=GitTools.DIFF,
                description="Shows differences between branches or commits",
                inputSchema=GitDiff.schema(),
            ),
            Tool(
                name=GitTools.COMMIT,
                description="Records changes to the repository",
                inputSchema=GitCommit.schema(),
            ),
            Tool(
                name=GitTools.ADD,
                description="Adds file contents to the staging area",
                inputSchema=GitAdd.schema(),
            ),
            Tool(
                name=GitTools.RESET,
                description="Unstages all staged changes",
                inputSchema=GitReset.schema(),
            ),
            Tool(
                name=GitTools.LOG,
                description="Shows the commit logs",
                inputSchema=GitLog.schema(),
            ),
            Tool(
                name=GitTools.CREATE_BRANCH,
                description="Creates a new branch from an optional base branch",
                inputSchema=GitCreateBranch.schema(),
            ),
            Tool(
                name=GitTools.CHECKOUT,
                description="Switches branches",
                inputSchema=GitCheckout.schema(),
            ),
            Tool(
                name=GitTools.SHOW,
                description="Shows the contents of a commit",
                inputSchema=GitShow.schema(),
            ),
            Tool(
                name=GitTools.WORKTREE_ADD,
                description="Add a new worktree for parallel development",
                inputSchema=GitWorktreeAdd.schema(),
            ),
            Tool(
                name=GitTools.WORKTREE_REMOVE,
                description="Remove a worktree",
                inputSchema=GitWorktreeRemove.schema(),
            ),
            Tool(
                name=GitTools.WORKTREE_LIST,
                description="List all worktrees",
                inputSchema=GitWorktreeList.schema(),
            ),
            Tool(
                name=GitTools.PUSH,
                description="Push commits to remote repository",
                inputSchema=GitPush.schema(),
            ),
            Tool(
                name=GitTools.REMOTE,
                description="Manage remote repositories (list, add, remove, get-url)",
                inputSchema=GitRemote.schema(),
            )
        ]

    @server.list_prompts()
    async def list_prompts() -> list[Prompt]:
        """List available git-related prompts"""
        return [
            Prompt(
                name="commit-message",
                description="Analyze commit patterns against principles and identify procedural gaps",
                arguments=[
                    PromptArgument(
                        name="commit_count",
                        description="Number of recent commits to analyze (default: 100)",
                        required=False
                    )
                ]
            ),
            Prompt(
                name="pr-description", 
                description="Generate comprehensive PR descriptions from git diff and commit history",
                arguments=[
                    PromptArgument(
                        name="base_branch",
                        description="Base branch for comparison (default: main)",
                        required=False
                    )
                ]
            )
        ]

    @server.get_prompt()
    async def get_prompt(name: str, arguments: dict | None = None) -> GetPromptResult:
        """Get a specific prompt with git context injected"""
        if arguments is None:
            arguments = {}
            
        # Get git context from available repositories
        repos = await list_repos()
        if not repos:
            return GetPromptResult(
                description=f"Prompt: {name}",
                messages=[
                    PromptMessage(
                        role="user",
                        content=TextContent(
                            type="text",
                            text="No git repository found. Please run this from a git repository."
                        )
                    )
                ]
            )
        
        # Use the first available repository
        repo_path = repos[0]
        try:
            repo = git.Repo(repo_path)
        except git.InvalidGitRepositoryError:
            return GetPromptResult(
                description=f"Prompt: {name}",
                messages=[
                    PromptMessage(
                        role="user", 
                        content=TextContent(
                            type="text",
                            text=f"Invalid git repository: {repo_path}"
                        )
                    )
                ]
            )
        
        if name == "commit-message":
            # Get extended git log for pattern analysis
            commit_count = int(arguments.get("commit_count", 100))
            
            try:
                log = git_log(repo, commit_count)
            except Exception as e:
                log = ["Unable to get git log"]
            
            prompt_text = f"""# Commit Pattern Analysis Against Principles

You are an expert at analyzing development patterns and identifying gaps between stated principles and actual practice. Based on my recent commit history, help me understand what my work patterns reveal about my priorities and where my procedures might be failing me.

## My Core Principles

**Systems Stewardship**: Maintaining and improving systems through consistent patterns, documentation, and procedures that enable sustainable growth and knowledge transfer.

**Versioning Mindset**: Progress through iteration rather than reinvention, where small strategic changes compound over time through active feedback loops.

**Subtraction Creates Value**: Strategic removal often creates more value than addition.

**Tracer Bullets**: Rapid feedback-driven development with ground truth at each step.

**Invent and Simplify**: Emphasis on simplification, malleability, usefulness, and utilitarian design.

**Do, Don't Explain**: Act like an agent, not a chatbot. Execute tasks directly rather than outputting walls of text.

**Transparency in Agent Work**: Make agent reasoning visible, especially during post-feature review cycles.

## Context

**Recent Commits (last {commit_count} commits):**
```
{chr(10).join(log)}
```

## Analysis Questions

1. **Principle Representation**: Which principles are over/under-represented in my commit patterns?

2. **Tension Points**: What tensions between principles show up in my work? (e.g., Do, Don't Explain vs Transparency in Agent Work)

3. **Procedural Gaps**: What procedures seem to be missing or not serving me well based on repeated patterns?

4. **Systems Stewardship Health**: Am I building sustainable, transferable knowledge or creating tribal knowledge?

5. **Iteration vs Reinvention**: Are my changes building on previous work or starting from scratch too often?

## Task

Analyze my commit patterns and provide:

1. **Principle Alignment**: Which principles are well-represented vs neglected in my actual work
2. **Hidden Tensions**: What conflicts between principles are showing up in practice
3. **Procedural Recommendations**: What new procedures or rule changes would serve me better
4. **Pattern Insights**: What does my commit history reveal about my actual priorities vs stated ones

Be direct and actionable. Focus on gaps between intention and execution."""

            return GetPromptResult(
                description="Analyze commit patterns against principles and identify procedural gaps",
                messages=[
                    PromptMessage(
                        role="user",
                        content=TextContent(type="text", text=prompt_text)
                    )
                ]
            )
            
        elif name == "pr-description":
            # Get git context
            base_branch = arguments.get("base_branch", "main")
            try:
                log = git_log(repo, 10)
                # Try to get diff from base branch, fallback to recent commits
                try:
                    diff_output = repo.git.diff(f"{base_branch}..HEAD")
                except:
                    diff_output = repo.git.diff("HEAD~5..HEAD")
                status = git_status(repo)
            except Exception as e:
                log = ["Unable to get git log"]
                diff_output = "Unable to get git diff"
                status = "Unable to get git status"
            
            prompt_text = f"""# Pull Request Description Generator

You are an expert at writing clear, comprehensive pull request descriptions. Based on the changes and commit history, generate a PR description that helps reviewers understand the changes.

## Guidelines

- Start with a clear summary of what this PR does
- Include motivation/context for the changes
- List key changes and their impact
- Highlight any breaking changes
- Include testing information
- Add any relevant screenshots or examples

## Context

**Recent Commits:**
```
{chr(10).join(log)}
```

**All Changes:**
```
{diff_output}
```

**Current Status:**
```
{status}
```

## Parameters

- Base branch: {base_branch}

## Task

Generate a comprehensive PR description that includes:

1. **Summary**: What does this PR do?
2. **Motivation**: Why are these changes needed?
3. **Changes**: Key modifications made
4. **Testing**: How were these changes tested?
5. **Breaking Changes**: Any breaking changes (if applicable)
6. **Additional Notes**: Anything else reviewers should know

Format the output as markdown suitable for GitHub PR description."""

            return GetPromptResult(
                description="Generate comprehensive PR descriptions from git diff and commit history",
                messages=[
                    PromptMessage(
                        role="user",
                        content=TextContent(type="text", text=prompt_text)
                    )
                ]
            )
        
        else:
            return GetPromptResult(
                description=f"Unknown prompt: {name}",
                messages=[
                    PromptMessage(
                        role="user",
                        content=TextContent(
                            type="text",
                            text=f"Unknown prompt: {name}. Available prompts: commit-message, pr-description"
                        )
                    )
                ]
            )

    async def list_repos() -> Sequence[str]:
        async def by_roots() -> Sequence[str]:
            if not isinstance(server.request_context.session, ServerSession):
                raise TypeError("server.request_context.session must be a ServerSession")

            if not server.request_context.session.check_client_capability(
                ClientCapabilities(roots=RootsCapability())
            ):
                return []

            roots_result: ListRootsResult = await server.request_context.session.list_roots()
            logger.debug(f"Roots result: {roots_result}")
            repo_paths = []
            for root in roots_result.roots:
                path = root.uri.path
                try:
                    git.Repo(path)
                    repo_paths.append(str(path))
                except git.InvalidGitRepositoryError:
                    pass
            return repo_paths

        def by_commandline() -> Sequence[str]:
            return [str(repository)] if repository is not None else []

        cmd_repos = by_commandline()
        root_repos = await by_roots()
        return [*root_repos, *cmd_repos]

    @server.call_tool()
    async def call_tool(name: str, arguments: dict) -> list[TextContent]:
        repo_path = Path(arguments["repo_path"])
        
        try:
            repo = git.Repo(repo_path)
        except git.InvalidGitRepositoryError as e:
            error_msg = f"Invalid git repository: {repo_path}"
            log_tool_error("atxtechbro-git-mcp-server", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]
        except Exception as e:
            error_msg = f"Failed to access repository: {str(e)}"
            log_tool_error("atxtechbro-git-mcp-server", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]

        try:
            match name:
                case GitTools.STATUS:
                    status = git_status(repo)
                    log_tool_success("atxtechbro-git-mcp-server", name, "Retrieved repository status", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=f"Repository status:\n{status}"
                    )]

                case GitTools.DIFF_UNSTAGED:
                    diff = git_diff_unstaged(repo)
                    log_tool_success("atxtechbro-git-mcp-server", name, "Retrieved unstaged changes", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=f"Unstaged changes:\n{diff}"
                    )]

                case GitTools.DIFF_STAGED:
                    diff = git_diff_staged(repo)
                    log_tool_success("atxtechbro-git-mcp-server", name, "Retrieved staged changes", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=f"Staged changes:\n{diff}"
                    )]

                case GitTools.DIFF:
                    diff = git_diff(repo, arguments["target"])
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Retrieved diff with {arguments['target']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=f"Diff with {arguments['target']}:\n{diff}"
                    )]

                case GitTools.COMMIT:
                    result = git_commit(repo, arguments["message"])
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Committed with message: {arguments['message']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                )]

                case GitTools.ADD:
                    result = git_add(repo, arguments["files"])
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Added files: {arguments['files']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.RESET:
                    result = git_reset(repo)
                    log_tool_success("atxtechbro-git-mcp-server", name, "Reset staged changes", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.LOG:
                    log = git_log(repo, arguments.get("max_count", 10))
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Retrieved {len(log)} commits", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text="Commit history:\n" + "\n".join(log)
                    )]

                case GitTools.CREATE_BRANCH:
                    result = git_create_branch(
                        repo,
                        arguments["branch_name"],
                        arguments.get("base_branch")
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Created branch: {arguments['branch_name']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.CHECKOUT:
                    result = git_checkout(repo, arguments["branch_name"])
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Checked out branch: {arguments['branch_name']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.SHOW:
                    result = git_show(repo, arguments["revision"])
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Showed revision: {arguments['revision']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.WORKTREE_ADD:
                    result = git_worktree_add(
                        repo, 
                        arguments["worktree_path"],
                        arguments.get("branch_name"),
                        arguments.get("create_branch", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Added worktree at {arguments['worktree_path']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.WORKTREE_REMOVE:
                    result = git_worktree_remove(
                        repo,
                        arguments["worktree_path"],
                        arguments.get("force", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Removed worktree at {arguments['worktree_path']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.WORKTREE_LIST:
                    result = git_worktree_list(repo)
                    log_tool_success("atxtechbro-git-mcp-server", name, "Listed worktrees", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.PUSH:
                    result = git_push(
                        repo,
                        arguments.get("remote", "origin"),
                        arguments.get("branch"),
                        arguments.get("set_upstream", False),
                        arguments.get("force", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Pushed to {arguments.get('remote', 'origin')}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.REMOTE:
                    result = git_remote(
                        repo,
                        arguments["action"],
                        arguments.get("name"),
                        arguments.get("url")
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Remote action: {arguments['action']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case _:
                    error_msg = f"Unknown tool: {name}"
                    log_tool_error("atxtechbro-git-mcp-server", name, error_msg, repo_path, arguments)
                    raise ValueError(error_msg)
                    
        except Exception as e:
            error_msg = f"Tool execution failed: {str(e)}"
            log_tool_error("atxtechbro-git-mcp-server", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]

    options = server.create_initialization_options()
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, options, raise_exceptions=True)
