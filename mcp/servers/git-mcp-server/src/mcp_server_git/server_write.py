"""Git MCP server - write operations"""
import logging
from pathlib import Path
from typing import Sequence

import git
from mcp.server import Server
from mcp.server.session import ServerSession
from mcp.server.stdio import stdio_server
from mcp.types import (
    ClientCapabilities,
    ListRootsResult,
    RootsCapability,
    TextContent,
    Tool,
)

from .logging_utils import log_tool_error, log_tool_success
from .base import (
    # Import models
    GitCommit, GitAdd, GitReset, GitCreateBranch, GitCheckout,
    GitWorktreeAdd, GitWorktreeRemove, GitPush, GitPull, GitFetch,
    GitMerge, GitRemote, GitBatch, GitRebase, GitStash, GitStashPop,
    GitCherryPick, GitRevert, GitResetHard, GitBranchDelete, GitClean,
    GitBisect,
    # Import enum
    GitTools, WRITE_TOOLS,
    # Import functions
    git_commit, git_add, git_reset, git_create_branch, git_checkout,
    git_worktree_add, git_worktree_remove, git_push, git_pull, git_fetch,
    git_merge, git_remote, git_batch, git_rebase, git_stash, git_stash_pop,
    git_cherry_pick, git_revert, git_reset_hard, git_branch_delete,
    git_clean, git_bisect,
)

# Tools allowed in write server - all write tools plus shared tools
ALLOWED_TOOLS = [tool.value for tool in WRITE_TOOLS] + [
    GitTools.REMOTE.value,  # All actions allowed
    GitTools.BATCH.value,   # Can run write commands
]

async def serve(repository: Path | None) -> None:
    logger = logging.getLogger(__name__)

    if repository is not None:
        try:
            git.Repo(repository)
            logger.info(f"Using repository at {repository}")
        except git.InvalidGitRepositoryError:
            logger.error(f"{repository} is not a valid Git repository")
            return

    server = Server("mcp-git-write")

    @server.list_tools()
    async def list_tools() -> list[Tool]:
        return [
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
                name=GitTools.PUSH,
                description="Push commits to remote repository (branch required, main blocked)",
                inputSchema=GitPush.schema(),
            ),
            Tool(
                name=GitTools.PULL,
                description="Pull changes from remote repository",
                inputSchema=GitPull.schema(),
            ),
            Tool(
                name=GitTools.FETCH,
                description="Fetch updates from remote repository without merging",
                inputSchema=GitFetch.schema(),
            ),
            Tool(
                name=GitTools.MERGE,
                description="Merge branches with support for different strategies",
                inputSchema=GitMerge.schema(),
            ),
            Tool(
                name=GitTools.REMOTE,
                description="Manage remote repositories (list, add, remove, get-url)",
                inputSchema=GitRemote.schema(),
            ),
            Tool(
                name=GitTools.BATCH,
                description="Execute multiple git commands in sequence",
                inputSchema=GitBatch.schema(),
            ),
            Tool(
                name=GitTools.REBASE,
                description="Rebase current branch onto another branch (supports --continue, --skip, --abort)",
                inputSchema=GitRebase.schema(),
            ),
            Tool(
                name=GitTools.STASH,
                description="Stash the changes in a dirty working directory away",
                inputSchema=GitStash.schema(),
            ),
            Tool(
                name=GitTools.STASH_POP,
                description="Apply and remove stashed changes",
                inputSchema=GitStashPop.schema(),
            ),
            Tool(
                name=GitTools.CHERRY_PICK,
                description="Cherry-pick commits onto the current branch (supports --continue, --skip, --abort)",
                inputSchema=GitCherryPick.schema(),
            ),
            Tool(
                name=GitTools.REVERT,
                description="Create a new commit that undoes a previous commit",
                inputSchema=GitRevert.schema(),
            ),
            Tool(
                name=GitTools.RESET_HARD,
                description="Hard reset to a specific commit (DESTRUCTIVE - discards all changes)",
                inputSchema=GitResetHard.schema(),
            ),
            Tool(
                name=GitTools.BRANCH_DELETE,
                description="Delete local and optionally remote branches",
                inputSchema=GitBranchDelete.schema(),
            ),
            Tool(
                name=GitTools.CLEAN,
                description="Remove untracked files and directories (DESTRUCTIVE - use dry_run first)",
                inputSchema=GitClean.schema(),
            ),
            Tool(
                name=GitTools.BISECT,
                description="Binary search to find commit that introduced a bug (actions: start, bad, good, skip, reset, view)",
                inputSchema=GitBisect.schema(),
            ),
        ]

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
        # Check if tool is allowed in write server
        if name not in ALLOWED_TOOLS:
            error_msg = f"Tool '{name}' is not available in write server"
            log_tool_error("atxtechbro-git-mcp-server-write", name, error_msg, None, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]
            
        repo_path = Path(arguments["repo_path"])
        
        try:
            repo = git.Repo(repo_path)
        except git.InvalidGitRepositoryError as e:
            error_msg = f"Invalid git repository: {repo_path}"
            log_tool_error("atxtechbro-git-mcp-server-write", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]
        except Exception as e:
            error_msg = f"Failed to access repository: {str(e)}"
            log_tool_error("atxtechbro-git-mcp-server-write", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]

        try:
            match name:
                case GitTools.COMMIT:
                    result = git_commit(repo, arguments["message"])
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Committed with message: {arguments['message']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.ADD:
                    result = git_add(repo, arguments["files"])
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Added files: {arguments['files']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.RESET:
                    result = git_reset(repo)
                    log_tool_success("atxtechbro-git-mcp-server-write", name, "Reset staged changes", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.CREATE_BRANCH:
                    result = git_create_branch(
                        repo,
                        arguments["branch_name"],
                        arguments.get("base_branch")
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Created branch: {arguments['branch_name']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.CHECKOUT:
                    result = git_checkout(repo, arguments["branch_name"])
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Checked out branch: {arguments['branch_name']}", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Added worktree at {arguments['worktree_path']}", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Removed worktree at {arguments['worktree_path']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.PUSH:
                    result = git_push(
                        repo,
                        arguments.get("remote", "origin"),
                        arguments["branch"],
                        arguments.get("set_upstream", False),
                        arguments.get("force", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Pushed to {arguments.get('remote', 'origin')}/{arguments['branch']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.PULL:
                    result = git_pull(
                        repo,
                        arguments.get("remote", "origin"),
                        arguments.get("branch"),
                        arguments.get("rebase", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, "Pulled changes", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.FETCH:
                    result = git_fetch(
                        repo,
                        arguments.get("remote", "origin"),
                        arguments.get("branch"),
                        arguments.get("fetch_all", False),
                        arguments.get("prune", False),
                        arguments.get("tags", True)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, "Fetched updates", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.MERGE:
                    result = git_merge(
                        repo,
                        arguments["branch"],
                        arguments.get("message"),
                        arguments.get("strategy"),
                        arguments.get("abort", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Merged branch: {arguments['branch']}", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Remote action: {arguments['action']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.BATCH:
                    # Execute batch with allowed tools
                    result = git_batch(repo, arguments["commands"], ALLOWED_TOOLS)
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Executed {len(arguments['commands'])} commands", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=str(result)
                    )]

                case GitTools.REBASE:
                    result = git_rebase(
                        repo,
                        arguments.get("onto"),
                        arguments.get("interactive", False),
                        arguments.get("continue_rebase", False),
                        arguments.get("skip", False),
                        arguments.get("abort", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, "Performed rebase operation", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.STASH:
                    result = git_stash(
                        repo,
                        arguments.get("action", "push"),
                        arguments.get("message"),
                        arguments.get("stash_ref"),
                        arguments.get("keep_index", False),
                        arguments.get("include_untracked", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Stash action: {arguments.get('action', 'push')}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.STASH_POP:
                    result = git_stash_pop(
                        repo,
                        arguments.get("stash_ref"),
                        arguments.get("index", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, "Popped stash", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.CHERRY_PICK:
                    result = git_cherry_pick(
                        repo,
                        arguments["commits"],
                        arguments.get("no_commit", False),
                        arguments.get("continue_pick", False),
                        arguments.get("skip", False),
                        arguments.get("abort", False),
                        arguments.get("mainline_parent")
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, "Performed cherry-pick", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.REVERT:
                    result = git_revert(
                        repo,
                        arguments["commits"],
                        arguments.get("no_commit", False),
                        arguments.get("no_edit", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, "Reverted commits", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.RESET_HARD:
                    result = git_reset_hard(repo, arguments.get("ref", "HEAD"))
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Hard reset to {arguments.get('ref', 'HEAD')}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.BRANCH_DELETE:
                    result = git_branch_delete(
                        repo,
                        arguments["branch_name"],
                        arguments.get("force", False),
                        arguments.get("remote", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Deleted branch: {arguments['branch_name']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.CLEAN:
                    result = git_clean(
                        repo,
                        arguments.get("force", False),
                        arguments.get("directories", False),
                        arguments.get("ignored", False),
                        arguments.get("dry_run", True)
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, "Cleaned working directory", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.BISECT:
                    result = git_bisect(
                        repo,
                        arguments["action"],
                        arguments.get("bad_commit"),
                        arguments.get("good_commit")
                    )
                    log_tool_success("atxtechbro-git-mcp-server-write", name, f"Bisect action: {arguments['action']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case _:
                    error_msg = f"Unknown tool: {name}"
                    log_tool_error("atxtechbro-git-mcp-server-write", name, error_msg, repo_path, arguments)
                    return [TextContent(type="text", text=f"Error: {error_msg}")]

        except Exception as e:
            error_msg = str(e)
            log_tool_error("atxtechbro-git-mcp-server-write", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]

    @server.list_roots()
    async def list_roots() -> list[dict]:
        return []

    options = server.create_initialization_options()
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, options, raise_exceptions=True)


def main():
    """Entry point for mcp-server-git-write command"""
    import sys
    repository = Path(sys.argv[1]) if len(sys.argv) > 1 else None
    import asyncio
    asyncio.run(serve(repository))

if __name__ == "__main__":
    main()