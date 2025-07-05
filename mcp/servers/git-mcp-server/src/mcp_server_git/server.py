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

# Define read-only and write tools
READ_ONLY_TOOLS = {
    "git_status",
    "git_diff_unstaged", 
    "git_diff_staged",
    "git_diff",
    "git_log",
    "git_show",
    "git_worktree_list",
    "git_reflog",
    "git_blame",
    "git_describe",
    "git_shortlog",
    "git_remote",  # Will be limited to list action only
    "git_fetch",   # Safe - only downloads data
    "git_branch_delete",  # Will be limited to local branches only
    "git_branch",  # Read-only list operation
}

WRITE_TOOLS = {
    "git_commit",
    "git_add",
    "git_reset",
    "git_create_branch",
    "git_checkout",
    "git_worktree_add",
    "git_worktree_remove",
    "git_push",
    "git_pull",
    "git_merge",
    "git_rebase",
    "git_stash",
    "git_stash_pop",
    "git_cherry_pick",
    "git_revert",
    "git_reset_hard",
    "git_clean",
    "git_bisect",
    "git_mv",
    "git_rm",
    "git_restore",
    "git_tag",
}

# git_batch is special - it can be in both depending on the commands it contains

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
    branch: str
    set_upstream: bool = False
    force: bool = False

class GitPull(BaseModel):
    repo_path: str
    remote: str = "origin"
    branch: str | None = None
    rebase: bool = False

class GitMerge(BaseModel):
    repo_path: str
    branch: str  # Branch to merge into current
    message: str | None = None  # Custom merge commit message
    strategy: str | None = None  # "ff-only", "no-ff", "squash"
    abort: bool = False  # For aborting a merge in progress

class GitRemote(BaseModel):
    repo_path: str
    action: str  # "list", "add", "remove", "get-url"
    name: str | None = None
    url: str | None = None

class GitBatch(BaseModel):
    repo_path: str
    commands: list[dict]  # List of {"tool": "git_add", "args": {...}}

class GitFetch(BaseModel):
    repo_path: str
    remote: str = "origin"
    branch: str | None = None  # Specific branch to fetch
    fetch_all: bool = False  # Fetch all remotes
    prune: bool = False  # Remove deleted remote branches
    tags: bool = True  # Fetch tags

class GitRebase(BaseModel):
    repo_path: str
    onto: str | None = None  # Branch to rebase onto
    interactive: bool = False
    continue_rebase: bool = False
    skip: bool = False
    abort: bool = False

class GitStash(BaseModel):
    repo_path: str
    action: str = "push"  # "push", "pop", "apply", "list", "drop", "clear", "show"
    message: str | None = None  # For push action
    stash_ref: str | None = None  # For pop/apply/drop/show (e.g., "stash@{0}")
    keep_index: bool = False  # Keep staged changes
    include_untracked: bool = False  # Include untracked files

class GitStashPop(BaseModel):
    repo_path: str
    stash_ref: str | None = None  # Specific stash to pop (e.g., "stash@{0}")
    index: bool = False  # Restore staged changes

class GitCherryPick(BaseModel):
    repo_path: str
    commits: list[str] | str  # Single commit or list of commits
    no_commit: bool = False  # Stage changes without committing
    continue_pick: bool = False
    skip: bool = False
    abort: bool = False
    mainline_parent: int | None = None  # For merge commits

class GitReflog(BaseModel):
    repo_path: str
    max_count: int = 30  # Number of reflog entries to show
    ref: str | None = None  # Specific ref to show reflog for (e.g., HEAD, branch name)

class GitBlame(BaseModel):
    repo_path: str
    file_path: str  # Path to the file to blame
    line_range: str | None = None  # Line range (e.g., "10,20" or "10,+5")

class GitRevert(BaseModel):
    repo_path: str
    commits: list[str] | str  # Single commit or list of commits to revert
    no_commit: bool = False  # Stage changes without committing
    no_edit: bool = False  # Use default commit message

class GitResetHard(BaseModel):
    repo_path: str
    ref: str = "HEAD"  # Commit/branch/tag to reset to

class GitBranchDelete(BaseModel):
    repo_path: str
    branch_name: str  # Branch to delete
    force: bool = False  # Force delete even if not merged
    remote: bool = False  # Delete remote branch as well

class GitClean(BaseModel):
    repo_path: str
    force: bool = False  # Required to actually delete files
    directories: bool = False  # Also remove untracked directories
    ignored: bool = False  # Also remove ignored files
    dry_run: bool = True  # Show what would be deleted without deleting

class GitBisect(BaseModel):
    repo_path: str
    action: str  # "start", "bad", "good", "skip", "reset", "view"
    bad_commit: str | None = None  # For start action
    good_commit: str | None = None  # For start action

class GitDescribe(BaseModel):
    repo_path: str
    commit: str | None = None  # Commit to describe (default: HEAD)
    tags: bool = True  # Use tags for description
    all: bool = False  # Use all refs, not just annotated tags
    long: bool = False  # Always output long format

class GitShortlog(BaseModel):
    repo_path: str
    revision_range: str | None = None  # e.g., "v1.0..HEAD" or "main"
    numbered: bool = True  # Show number of commits per author
    summary: bool = True  # Suppress commit descriptions
    email: bool = False  # Show author emails

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
    PULL = "git_pull"
    FETCH = "git_fetch"
    MERGE = "git_merge"
    REMOTE = "git_remote"
    BATCH = "git_batch"
    REBASE = "git_rebase"
    STASH = "git_stash"
    STASH_POP = "git_stash_pop"
    CHERRY_PICK = "git_cherry_pick"
    REFLOG = "git_reflog"
    BLAME = "git_blame"
    REVERT = "git_revert"
    RESET_HARD = "git_reset_hard"
    BRANCH_DELETE = "git_branch_delete"
    CLEAN = "git_clean"
    BISECT = "git_bisect"
    DESCRIBE = "git_describe"
    SHORTLOG = "git_shortlog"
    MV = "git_mv"
    RM = "git_rm"
    RESTORE = "git_restore"
    TAG = "git_tag"
    BRANCH = "git_branch"

class GitMv(BaseModel):
    repo_path: str
    source: str
    destination: str

class GitRm(BaseModel):
    repo_path: str
    files: list[str]
    cached: bool = False  # Remove from index only
    force: bool = False  # Override up-to-date check
    recursive: bool = False  # Remove directory contents recursively

class GitRestore(BaseModel):
    repo_path: str
    files: list[str]
    source: str | None = None  # Restore from specific commit/branch
    staged: bool = False  # Restore staged version
    worktree: bool = True  # Restore working tree files

class GitTag(BaseModel):
    repo_path: str
    action: str = "create"  # "create", "list", "delete", "verify"
    tag_name: str | None = None  # Tag name for create/delete
    message: str | None = None  # Annotation message
    ref: str | None = None  # Object to tag (default: HEAD)
    force: bool = False  # Replace existing tag
    annotated: bool = True  # Create annotated tag
    pattern: str | None = None  # Pattern for list

class GitBranch(BaseModel):
    repo_path: str
    action: str = "list"  # "list" - we already have create/delete
    all: bool = False  # List both remote and local branches
    remotes: bool = False  # List remote branches only
    pattern: str | None = None  # Pattern to match branch names

# Tool registry for easy access
TOOL_REGISTRY = {
    GitTools.STATUS: (GitStatus, "Shows the working tree status"),
    GitTools.DIFF_UNSTAGED: (GitDiffUnstaged, "Shows changes in the working directory that are not yet staged"),
    GitTools.DIFF_STAGED: (GitDiffStaged, "Shows changes that are staged for commit"),
    GitTools.DIFF: (GitDiff, "Shows differences between branches or commits"),
    GitTools.COMMIT: (GitCommit, "Records changes to the repository"),
    GitTools.ADD: (GitAdd, "Adds file contents to the staging area"),
    GitTools.RESET: (GitReset, "Unstages all staged changes"),
    GitTools.LOG: (GitLog, "Shows the commit logs"),
    GitTools.CREATE_BRANCH: (GitCreateBranch, "Creates a new branch from an optional base branch"),
    GitTools.CHECKOUT: (GitCheckout, "Switches branches"),
    GitTools.SHOW: (GitShow, "Shows the contents of a commit"),
    GitTools.WORKTREE_ADD: (GitWorktreeAdd, "Add a new worktree for parallel development"),
    GitTools.WORKTREE_REMOVE: (GitWorktreeRemove, "Remove a worktree"),
    GitTools.WORKTREE_LIST: (GitWorktreeList, "List all worktrees"),
    GitTools.PUSH: (GitPush, "Push commits to remote repository (branch required, main blocked)"),
    GitTools.PULL: (GitPull, "Pull changes from remote repository"),
    GitTools.FETCH: (GitFetch, "Fetch updates from remote repository without merging"),
    GitTools.MERGE: (GitMerge, "Merge branches with support for different strategies"),
    GitTools.REMOTE: (GitRemote, "Manage remote repositories (list, add, remove, get-url)"),
    GitTools.BATCH: (GitBatch, "Execute multiple git commands in sequence"),
    GitTools.REBASE: (GitRebase, "Rebase current branch onto another branch (supports --continue, --skip, --abort)"),
    GitTools.STASH: (GitStash, "Stash the changes in a dirty working directory away"),
    GitTools.STASH_POP: (GitStashPop, "Apply and remove stashed changes"),
    GitTools.CHERRY_PICK: (GitCherryPick, "Cherry-pick commits onto the current branch (supports --continue, --skip, --abort)"),
    GitTools.REFLOG: (GitReflog, "Show the reference log (reflog) for recovery and history inspection"),
    GitTools.BLAME: (GitBlame, "Show who last modified each line of a file"),
    GitTools.REVERT: (GitRevert, "Create a new commit that undoes a previous commit"),
    GitTools.RESET_HARD: (GitResetHard, "Hard reset to a specific commit (DESTRUCTIVE - discards all changes)"),
    GitTools.BRANCH_DELETE: (GitBranchDelete, "Delete local and optionally remote branches"),
    GitTools.CLEAN: (GitClean, "Remove untracked files and directories (DESTRUCTIVE - use dry_run first)"),
    GitTools.BISECT: (GitBisect, "Binary search to find commit that introduced a bug (actions: start, bad, good, skip, reset, view)"),
    GitTools.DESCRIBE: (GitDescribe, "Generate human-readable names for commits based on tags"),
    GitTools.SHORTLOG: (GitShortlog, "Summarize git log by contributor"),
    GitTools.MV: (GitMv, "Move or rename a file, directory, or symlink"),
    GitTools.RM: (GitRm, "Remove files from the working tree and from the index"),
    GitTools.RESTORE: (GitRestore, "Restore working tree files"),
    GitTools.TAG: (GitTag, "Create, list, delete or verify tags"),
    GitTools.BRANCH: (GitBranch, "List branches (create/delete already available separately)"),
}

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

def git_push(repo: git.Repo, remote: str = "origin", branch: str = None, set_upstream: bool = False, force: bool = False) -> str:
    """Push changes to remote repository"""
    # Branch is now mandatory
    if not branch:
        raise ValueError("Branch parameter is required for git_push")
    
    # Safety check: prevent pushing to main
    if branch == "main":
        raise ValueError("Direct pushes to main branch are not allowed. Please create a feature branch and use pull requests.")
    
    # Build command as a list
    cmd_parts = []
    
    if force:
        cmd_parts.append("--force")
    
    if set_upstream:
        cmd_parts.extend(["-u", remote, branch])
    else:
        cmd_parts.extend([remote, branch])
    
    # Use the git command directly through repo.git
    output = repo.git.push(*cmd_parts)
    
    return f"Pushed {branch} to {remote}" + (f" (tracking)" if set_upstream else "")

def git_pull(repo: git.Repo, remote: str = "origin", branch: str | None = None, rebase: bool = False) -> str:
    """Pull changes from remote repository"""
    # Build command as a list
    cmd_parts = []
    
    if rebase:
        cmd_parts.append("--rebase")
    
    cmd_parts.append(remote)
    
    if branch:
        cmd_parts.append(branch)
    
    # Use the git command directly through repo.git
    output = repo.git.pull(*cmd_parts)
    
    return output if output else f"Already up to date with {remote}" + (f"/{branch}" if branch else "")

def git_fetch(repo: git.Repo, remote: str = "origin", branch: str | None = None, fetch_all: bool = False, prune: bool = False, tags: bool = True) -> str:
    """Fetch changes from remote repository without merging"""
    # Build command as a list
    cmd_parts = []
    
    if fetch_all:
        cmd_parts.append("--all")
    
    if prune:
        cmd_parts.append("--prune")
    
    if not tags:
        cmd_parts.append("--no-tags")
    
    # Only add remote and branch if not fetching all
    if not fetch_all:
        cmd_parts.append(remote)
        
        if branch:
            cmd_parts.append(branch)
    
    # Use the git command directly through repo.git
    try:
        output = repo.git.fetch(*cmd_parts, verbose=True)
        
        # Parse the output to show what was fetched
        if output:
            lines = output.strip().split('\n')
            result_lines = []
            
            for line in lines:
                # Skip empty lines and connection info
                if line and not line.startswith('From '):
                    result_lines.append(line)
            
            if result_lines:
                return f"Fetched from {remote}:\n" + "\n".join(result_lines)
            else:
                return f"Already up to date with {remote}"
        else:
            return f"Already up to date with {remote}"
    except git.GitCommandError as e:
        # git fetch returns non-zero exit code even on success sometimes
        # Check if it's actually an error
        output = str(e.stdout)
        if output:
            return f"Fetched from {remote}:\n{output}"
        else:
            raise

def git_merge(repo: git.Repo, branch: str, message: str | None = None, strategy: str | None = None, abort: bool = False) -> str:
    """Merge branches with support for different strategies"""
    if abort:
        try:
            repo.git.merge("--abort")
            return "Merge aborted successfully"
        except git.GitCommandError as e:
            return f"Error aborting merge: {str(e)}"
    
    # Build merge command
    cmd_parts = []
    
    if strategy == "ff-only":
        cmd_parts.append("--ff-only")
    elif strategy == "no-ff":
        cmd_parts.append("--no-ff")
    elif strategy == "squash":
        cmd_parts.append("--squash")
    
    if message and strategy != "squash":  # Custom message doesn't apply to squash
        cmd_parts.extend(["-m", message])
    
    cmd_parts.append(branch)
    
    try:
        output = repo.git.merge(*cmd_parts)
        
        # If squash merge, we need to commit separately
        if strategy == "squash" and repo.index.diff("HEAD"):
            commit_msg = message or f"Squash merge branch '{branch}'"
            repo.index.commit(commit_msg)
            return f"Squash merged '{branch}' and committed"
        
        return output if output else f"Successfully merged '{branch}'"
    except git.GitCommandError as e:
        if "CONFLICT" in str(e):
            return f"Merge conflict detected. Resolve conflicts and commit, or run with --abort to cancel merge.\n{str(e)}"
        else:
            return f"Error during merge: {str(e)}"

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

def git_batch(repo: git.Repo, commands: list[dict]) -> list[dict]:
    """Execute multiple git commands in sequence"""
    results = []
    
    for cmd in commands:
        # Support both 'tool' and 'command' keys for backward compatibility
        tool = cmd.get("tool") or cmd.get("command")
        args = cmd.get("args", {})
        
        # Map shorthand commands to full tool names
        if tool == "mv":
            tool = "git_mv"
        elif tool == "rm":
            tool = "git_rm"
        elif tool == "restore":
            tool = "git_restore"
        elif tool == "tag":
            tool = "git_tag"
        elif tool == "branch":
            tool = "git_branch"
        
        try:
            if tool == "git_add":
                result = git_add(repo, args.get("files", []))
            elif tool == "git_commit":
                result = git_commit(repo, args.get("message", ""))
            elif tool == "git_push":
                result = git_push(repo, args.get("remote", "origin"), args.get("branch"), args.get("set_upstream", False), args.get("force", False))
            elif tool == "git_pull":
                result = git_pull(repo, args.get("remote", "origin"), args.get("branch"), args.get("rebase", False))
            elif tool == "git_fetch":
                result = git_fetch(repo, args.get("remote", "origin"), args.get("branch"), args.get("all", False), args.get("prune", False), args.get("tags", True))
            elif tool == "git_merge":
                result = git_merge(repo, args.get("branch"), args.get("message"), args.get("strategy"), args.get("abort", False))
            elif tool == "git_status":
                result = git_status(repo)
            elif tool == "git_create_branch":
                result = git_create_branch(repo, args.get("branch_name"), args.get("base_branch"))
            elif tool == "git_checkout":
                result = git_checkout(repo, args.get("branch_name"))
            elif tool == "git_rebase":
                result = git_rebase(repo, args.get("onto"), args.get("interactive", False), 
                                   args.get("continue_rebase", False), args.get("skip", False), 
                                   args.get("abort", False))
            elif tool == "git_stash":
                result = git_stash(repo, args.get("action", "push"), args.get("message"), 
                                 args.get("stash_ref"), args.get("keep_index", False), 
                                 args.get("include_untracked", False))
            elif tool == "git_stash_pop":
                result = git_stash_pop(repo, args.get("stash_ref"), args.get("index", False))
            elif tool == "git_reflog":
                result = git_reflog(repo, args.get("max_count", 30), args.get("ref"))
            elif tool == "git_blame":
                result = git_blame(repo, args.get("file_path"), args.get("line_range"))
            elif tool == "git_revert":
                result = git_revert(repo, args.get("commits"), args.get("no_commit", False), args.get("no_edit", False))
            elif tool == "git_reset_hard":
                result = git_reset_hard(repo, args.get("ref", "HEAD"))
            elif tool == "git_branch_delete":
                result = git_branch_delete(repo, args.get("branch_name"), args.get("force", False), args.get("remote", False))
            elif tool == "git_clean":
                result = git_clean(repo, args.get("force", False), args.get("directories", False), 
                                 args.get("ignored", False), args.get("dry_run", True))
            elif tool == "git_bisect":
                result = git_bisect(repo, args.get("action"), args.get("bad_commit"), args.get("good_commit"))
            elif tool == "git_describe":
                result = git_describe(repo, args.get("commit"), args.get("tags", True), 
                                    args.get("all", False), args.get("long", False))
            elif tool == "git_shortlog":
                result = git_shortlog(repo, args.get("revision_range"), args.get("numbered", True),
                                    args.get("summary", True), args.get("email", False))
            elif tool == "git_mv":
                # Handle both single args and array args for git_mv
                if isinstance(args, list) and len(args) >= 2:
                    # Legacy format: args as array [source, destination]
                    result = git_mv(repo, args[0], args[1])
                else:
                    # Standard format: args as object with source and destination
                    result = git_mv(repo, args.get("source"), args.get("destination"))
            elif tool == "git_rm":
                result = git_rm(repo, args.get("files", []), args.get("cached", False), 
                               args.get("force", False), args.get("recursive", False))
            elif tool == "git_restore":
                result = git_restore(repo, args.get("files", []), args.get("source"), 
                                   args.get("staged", False), args.get("worktree", True))
            elif tool == "git_tag":
                result = git_tag(repo, args.get("action", "create"), args.get("tag_name"), 
                               args.get("message"), args.get("ref"), args.get("force", False), 
                               args.get("annotated", True), args.get("pattern"))
            elif tool == "git_branch":
                result = git_branch(repo, args.get("action", "list"), args.get("all", False), 
                                  args.get("remotes", False), args.get("pattern"))
            else:
                result = f"Unknown tool: {tool}"
            
            results.append({"tool": tool, "status": "success", "result": result})
        except Exception as e:
            results.append({"tool": tool, "status": "error", "error": str(e)})
            break  # Stop on first error
    
    return results

def git_rebase(repo: git.Repo, onto: str | None = None, interactive: bool = False, 
               continue_rebase: bool = False, skip: bool = False, abort: bool = False) -> str:
    """Handle git rebase operations"""
    
    # Handle rebase control operations
    if abort:
        try:
            repo.git.rebase("--abort")
            return "Rebase aborted successfully"
        except git.GitCommandError as e:
            return f"Error aborting rebase: {str(e)}"
    
    if continue_rebase:
        try:
            repo.git.rebase("--continue")
            return "Rebase continued successfully"
        except git.GitCommandError as e:
            if "No rebase in progress?" in str(e):
                return "No rebase in progress"
            return f"Error continuing rebase: {str(e)}"
    
    if skip:
        try:
            repo.git.rebase("--skip")
            return "Skipped current commit and continued rebase"
        except git.GitCommandError as e:
            if "No rebase in progress?" in str(e):
                return "No rebase in progress"
            return f"Error skipping commit: {str(e)}"
    
    # Start a new rebase
    if not onto:
        return "Error: 'onto' branch required for rebase operation"
    
    cmd_parts = []
    
    if interactive:
        # For interactive rebase, we'll use a simplified approach
        # In a real terminal environment, this would open an editor
        return "Interactive rebase is not fully supported in this environment. Use standard rebase instead."
    
    cmd_parts.append(onto)
    
    try:
        output = repo.git.rebase(*cmd_parts)
        return output if output else f"Successfully rebased onto '{onto}'"
    except git.GitCommandError as e:
        if "CONFLICT" in str(e):
            return f"Rebase conflict detected. Resolve conflicts and run with --continue, or --abort to cancel.\n{str(e)}"
        elif "up to date" in str(e).lower():
            return f"Current branch is up to date with '{onto}'"
        else:
            return f"Error during rebase: {str(e)}"

def git_stash(repo: git.Repo, action: str = "push", message: str | None = None, 
              stash_ref: str | None = None, keep_index: bool = False, 
              include_untracked: bool = False) -> str:
    """
    Handle various git stash operations
    """
    # Validate action against whitelist
    allowed_actions = ["push", "list", "show", "apply", "pop", "drop", "clear"]
    if action not in allowed_actions:
        return f"Unknown stash action: {action}. Allowed actions: {', '.join(allowed_actions)}"
    
    try:
        if action == "push":
            cmd_parts = ["stash", "push"]
            if message:
                cmd_parts.extend(["-m", message])
            if keep_index:
                cmd_parts.append("--keep-index")
            if include_untracked:
                cmd_parts.append("--include-untracked")
            
            output = repo.git.execute(cmd_parts)
            return output if output else "Changes stashed successfully"
            
        elif action == "list":
            output = repo.git.stash("list")
            return output if output else "No stashes found"
            
        elif action == "show":
            stash = stash_ref or "stash@{0}"
            output = repo.git.stash("show", "-p", stash)
            return output if output else f"No changes in {stash}"
            
        elif action == "drop":
            stash = stash_ref or "stash@{0}"
            output = repo.git.stash("drop", stash)
            return output if output else f"Dropped {stash}"
            
        elif action == "clear":
            output = repo.git.stash("clear")
            return output if output else "All stashes cleared"
            
        elif action == "pop":
            stash = stash_ref or "stash@{0}"
            output = repo.git.stash("pop", stash)
            return output if output else f"Applied and removed {stash}"
            
        elif action == "apply":
            stash = stash_ref or "stash@{0}"
            output = repo.git.stash("apply", stash)
            return output if output else f"Applied {stash}"
            
    except git.GitCommandError as e:
        # Handle Git-specific errors
        return f"Stash error: {str(e)}"
    except Exception as e:
        # Handle unexpected errors
        return f"Unexpected error during stash operation: {str(e)}"

def git_stash_pop(repo: git.Repo, stash_ref: str | None = None, index: bool = False) -> str:
    """
    Apply and remove stashed changes (convenience wrapper)
    """
    try:
        cmd_parts = ["stash", "pop"]
        if index:
            cmd_parts.append("--index")
        if stash_ref:
            cmd_parts.append(stash_ref)
            
        output = repo.git.execute(cmd_parts)
        
        stash = stash_ref or "stash@{0}"
        return output if output else f"Successfully applied and removed {stash}"
            
    except git.GitCommandError as e:
        if "CONFLICT" in str(e):
            return f"Merge conflict when applying stash. Stash was not removed.\n{str(e)}"
        elif "No stash entries found" in str(e):
            return "No stashes to pop"
        else:
            return f"Error popping stash: {str(e)}"

def git_cherry_pick(repo: git.Repo, commits: list[str] | str, no_commit: bool = False,
                   continue_pick: bool = False, skip: bool = False, abort: bool = False,
                   mainline_parent: int | None = None) -> str:
    """
    Cherry-pick commits onto the current branch
    """
    try:
        # Handle control flow options first
        if abort:
            output = repo.git.cherry_pick("--abort")
            return output if output else "Cherry-pick aborted"
        
        if continue_pick:
            output = repo.git.cherry_pick("--continue")
            return output if output else "Cherry-pick continued"
            
        if skip:
            output = repo.git.cherry_pick("--skip")
            return output if output else "Cherry-pick skipped"
        
        # Handle normal cherry-pick
        if isinstance(commits, str):
            commits = [commits]
        
        cmd_parts = ["cherry-pick"]
        
        if no_commit:
            cmd_parts.append("--no-commit")
            
        if mainline_parent is not None:
            cmd_parts.extend(["-m", str(mainline_parent)])
            
        cmd_parts.extend(commits)
        
        output = repo.git.execute(cmd_parts)
        
        # Prepare success message
        if len(commits) == 1:
            action = "staged" if no_commit else "applied"
            return output if output else f"Successfully {action} commit {commits[0]}"
        else:
            action = "staged" if no_commit else "applied"
            return output if output else f"Successfully {action} {len(commits)} commits"
            
    except git.GitCommandError as e:
        error_str = str(e)
        
        # Check for specific error conditions
        if "CONFLICT" in error_str:
            return f"Cherry-pick conflict detected. Resolve conflicts and use --continue\n{error_str}"
        elif "bad revision" in error_str:
            return f"Invalid commit reference: {error_str}"
        elif "cherry-pick is already in progress" in error_str:
            return "A cherry-pick is already in progress. Use --continue, --skip, or --abort"
        else:
            return f"Cherry-pick error: {error_str}"
    except Exception as e:
        return f"Unexpected error during cherry-pick: {str(e)}"

def git_reflog(repo: git.Repo, max_count: int = 30, ref: str | None = None) -> str:
    """
    Show the reference log (reflog) for recovery and history inspection
    """
    try:
        cmd_parts = ["reflog"]
        
        # Add count limit
        cmd_parts.extend(["-n", str(max_count)])
        
        # Add specific ref if provided
        if ref:
            cmd_parts.append(ref)
        
        output = repo.git.execute(cmd_parts)
        
        if not output:
            ref_name = ref or "HEAD"
            return f"No reflog entries found for {ref_name}"
            
        return output
        
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "ambiguous argument" in error_str:
            return f"Invalid reference: {ref}"
        elif "fatal: your current branch" in error_str:
            return f"No reflog available for {ref or 'current branch'}"
        else:
            return f"Reflog error: {error_str}"
    except Exception as e:
        return f"Unexpected error accessing reflog: {str(e)}"

def git_blame(repo: git.Repo, file_path: str, line_range: str | None = None) -> str:
    """
    Show who last modified each line of a file (line-by-line authorship)
    """
    try:
        cmd_parts = ["blame"]
        
        # Add line range if specified
        if line_range:
            cmd_parts.extend(["-L", line_range])
        
        # Add the file path
        cmd_parts.append(file_path)
        
        output = repo.git.execute(cmd_parts)
        
        if not output:
            return f"No blame information available for {file_path}"
            
        return output
        
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "no such path" in error_str:
            return f"File not found: {file_path}"
        elif "line range" in error_str:
            return f"Invalid line range: {line_range}"
        elif "fatal: no such ref" in error_str:
            return "File does not exist in the current branch"
        else:
            return f"Blame error: {error_str}"
    except Exception as e:
        return f"Unexpected error running git blame: {str(e)}"

def git_revert(repo: git.Repo, commits: list[str] | str, no_commit: bool = False, no_edit: bool = False) -> str:
    """
    Create a new commit that undoes a previous commit
    """
    try:
        # Ensure commits is a list
        if isinstance(commits, str):
            commits = [commits]
        
        cmd_parts = ["revert"]
        
        if no_commit:
            cmd_parts.append("--no-commit")
        
        if no_edit:
            cmd_parts.append("--no-edit")
        
        # Add commits to revert
        cmd_parts.extend(commits)
        
        output = repo.git.execute(cmd_parts)
        
        # Prepare success message
        if len(commits) == 1:
            action = "staged" if no_commit else "reverted"
            return output if output else f"Successfully {action} commit {commits[0]}"
        else:
            action = "staged" if no_commit else "reverted"
            return output if output else f"Successfully {action} {len(commits)} commits"
            
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "CONFLICT" in error_str:
            return f"Revert conflict detected. Resolve conflicts and commit manually\n{error_str}"
        elif "bad revision" in error_str:
            return f"Invalid commit reference: {error_str}"
        elif "cherry-pick is already in progress" in error_str:
            return "Cannot revert: a cherry-pick is already in progress"
        else:
            return f"Revert error: {error_str}"
    except Exception as e:
        return f"Unexpected error during revert: {str(e)}"

def git_reset_hard(repo: git.Repo, ref: str = "HEAD") -> str:
    """
    Hard reset to a specific commit (DESTRUCTIVE - discards all changes)
    """
    try:
        # Get current branch name for warning message
        try:
            current_branch = repo.active_branch.name
        except:
            current_branch = "detached HEAD"
        
        # Perform hard reset
        repo.git.reset("--hard", ref)
        
        # Get info about where we reset to
        try:
            reset_commit = repo.commit(ref)
            reset_info = f"{reset_commit.hexsha[:7]} - {reset_commit.summary}"
        except:
            reset_info = ref
        
        return f"Hard reset successful. Branch '{current_branch}' is now at {reset_info}\nWARNING: All uncommitted changes have been discarded!"
        
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "unknown revision" in error_str or "bad revision" in error_str:
            return f"Invalid reference: {ref}"
        elif "needs merge" in error_str:
            return "Cannot reset: You have unmerged files. Resolve conflicts first."
        else:
            return f"Reset error: {error_str}"
    except Exception as e:
        return f"Unexpected error during hard reset: {str(e)}"

def git_branch_delete(repo: git.Repo, branch_name: str, force: bool = False, remote: bool = False) -> str:
    """
    Delete local and optionally remote branches
    """
    try:
        results = []
        
        # Safety check: prevent deletion of main/master branches
        protected_branches = {"main", "master"}
        if branch_name.lower() in protected_branches:
            return f"Cannot delete protected branch '{branch_name}'. Direct deletion of main/master branches is not allowed for safety reasons."
        
        # Check if we're trying to delete the current branch
        try:
            current_branch = repo.active_branch.name
            if current_branch == branch_name:
                return f"Cannot delete the current branch '{branch_name}'. Switch to another branch first."
        except:
            pass  # Might be in detached HEAD state
        
        # Delete local branch
        try:
            if force:
                repo.git.branch("-D", branch_name)
            else:
                repo.git.branch("-d", branch_name)
            results.append(f"Deleted local branch '{branch_name}'")
        except git.GitCommandError as e:
            error_str = str(e)
            if "not found" in error_str:
                if not remote:
                    return f"Branch '{branch_name}' not found"
                # If only remote deletion requested, continue
            elif "not fully merged" in error_str:
                return f"Branch '{branch_name}' is not fully merged. Use force=true to delete anyway."
            else:
                return f"Error deleting local branch: {error_str}"
        
        # Delete remote branch if requested
        if remote:
            try:
                # Try to delete from origin by default
                repo.git.push("origin", "--delete", branch_name)
                results.append(f"Deleted remote branch 'origin/{branch_name}'")
            except git.GitCommandError as e:
                error_str = str(e)
                if "remote ref does not exist" in error_str:
                    results.append(f"Remote branch 'origin/{branch_name}' not found")
                else:
                    results.append(f"Error deleting remote branch: {error_str}")
        
        return "\n".join(results) if results else "No branches deleted"
        
    except Exception as e:
        return f"Unexpected error deleting branch: {str(e)}"

def git_clean(repo: git.Repo, force: bool = False, directories: bool = False, 
              ignored: bool = False, dry_run: bool = True) -> str:
    """
    Remove untracked files and directories (DESTRUCTIVE)
    """
    try:
        cmd_parts = ["clean"]
        
        # Build command flags
        flags = ""
        if dry_run:
            flags += "n"  # Dry run - show what would be deleted
        if force:
            flags += "f"  # Force - actually delete
        if directories:
            flags += "d"  # Include directories
        if ignored:
            flags += "x"  # Include ignored files
        
        if flags:
            cmd_parts.append(f"-{flags}")
        
        # Execute clean command
        output = repo.git.execute(cmd_parts)
        
        if not output:
            return "Nothing to clean - working directory is clean"
        
        # Format output based on mode
        if dry_run:
            lines = output.strip().split('\n')
            cleaned_lines = [line.replace("Would remove ", "") for line in lines if line]
            file_count = len(cleaned_lines)
            
            result = f"Would remove {file_count} item(s):\n"
            result += "\n".join(f"  - {item}" for item in cleaned_lines)
            result += "\n\nTo actually delete these files, run with dry_run=false and force=true"
            return result
        else:
            lines = output.strip().split('\n')
            cleaned_lines = [line.replace("Removing ", "") for line in lines if line]
            file_count = len(cleaned_lines)
            
            result = f"Successfully removed {file_count} item(s):\n"
            result += "\n".join(f"  - {item}" for item in cleaned_lines)
            return result
            
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "failed to remove" in error_str:
            return f"Failed to remove some files: {error_str}"
        else:
            return f"Clean error: {error_str}"
    except Exception as e:
        return f"Unexpected error during clean: {str(e)}"

def git_bisect(repo: git.Repo, action: str, bad_commit: str | None = None, good_commit: str | None = None) -> str:
    """
    Binary search to find commit that introduced a bug
    """
    try:
        # Validate action
        allowed_actions = ["start", "bad", "good", "skip", "reset", "view"]
        if action not in allowed_actions:
            return f"Unknown bisect action: {action}. Allowed actions: {', '.join(allowed_actions)}"
        
        if action == "start":
            # Start bisect
            try:
                repo.git.bisect("start")
                result = "Bisect started"
                
                # Mark bad commit if provided
                if bad_commit:
                    repo.git.bisect("bad", bad_commit)
                    result += f"\nMarked {bad_commit} as bad"
                
                # Mark good commit if provided
                if good_commit:
                    repo.git.bisect("good", good_commit)
                    result += f"\nMarked {good_commit} as good"
                    
                    # Get the commit to test
                    try:
                        output = repo.git.bisect("view")
                        if output and "Bisecting:" in output:
                            result += f"\n\n{output}"
                    except:
                        pass
                
                return result
            except git.GitCommandError as e:
                if "already started" in str(e):
                    return "Bisect already in progress. Use 'reset' to stop current bisect first."
                return f"Error starting bisect: {str(e)}"
        
        elif action == "bad":
            # Mark current commit as bad
            output = repo.git.bisect("bad")
            if "is the first bad commit" in output:
                return f"Bisect complete! First bad commit found:\n\n{output}"
            return output if output else "Marked current commit as bad"
        
        elif action == "good":
            # Mark current commit as good
            output = repo.git.bisect("good")
            if "is the first bad commit" in output:
                return f"Bisect complete! First bad commit found:\n\n{output}"
            return output if output else "Marked current commit as good"
        
        elif action == "skip":
            # Skip current commit
            output = repo.git.bisect("skip")
            return output if output else "Skipped current commit"
        
        elif action == "reset":
            # Reset bisect
            output = repo.git.bisect("reset")
            return output if output else "Bisect reset - returned to original branch"
        
        elif action == "view":
            # View current bisect status
            try:
                output = repo.git.bisect("view")
                if not output:
                    # Try to get log of bisect
                    log = repo.git.bisect("log")
                    if log:
                        return f"Bisect log:\n{log}"
                    return "No bisect in progress"
                return output
            except git.GitCommandError:
                return "No bisect in progress"
                
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "no terms defined" in error_str:
            return "No bisect in progress. Start with action='start'"
        elif "bad revision" in error_str:
            return f"Invalid commit reference"
        else:
            return f"Bisect error: {error_str}"
    except Exception as e:
        return f"Unexpected error during bisect: {str(e)}"

def git_describe(repo: git.Repo, commit: str | None = None, tags: bool = True, 
                all: bool = False, long: bool = False) -> str:
    """
    Generate human-readable names for commits based on tags
    """
    try:
        cmd_parts = ["describe"]
        
        # Add options
        if all:
            cmd_parts.append("--all")
        elif tags:
            cmd_parts.append("--tags")
        
        if long:
            cmd_parts.append("--long")
        
        # Add commit reference if provided
        if commit:
            cmd_parts.append(commit)
        
        output = repo.git.execute(cmd_parts)
        
        if output:
            # Get additional info about the commit
            try:
                commit_ref = commit or "HEAD"
                commit_obj = repo.commit(commit_ref)
                result = f"Description: {output}\n"
                result += f"Commit: {commit_obj.hexsha[:7]}\n"
                result += f"Author: {commit_obj.author}\n"
                result += f"Date: {commit_obj.authored_datetime}\n"
                result += f"Message: {commit_obj.summary}"
                return result
            except:
                # Fallback to just the description
                return output
        else:
            return "No description available (no tags found)"
            
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "No tags can describe" in error_str or "No names found" in error_str:
            # Try to provide helpful context
            try:
                commit_ref = commit or "HEAD"
                commit_obj = repo.commit(commit_ref)
                return f"No tags found to describe commit {commit_obj.hexsha[:7]}\nConsider creating a tag with 'git tag' first"
            except:
                return "No tags found in repository. Create tags to enable descriptions."
        elif "bad revision" in error_str:
            return f"Invalid commit reference: {commit}"
        else:
            return f"Describe error: {error_str}"
    except Exception as e:
        return f"Unexpected error during describe: {str(e)}"

def git_shortlog(repo: git.Repo, revision_range: str | None = None, 
                numbered: bool = True, summary: bool = True, email: bool = False) -> str:
    """
    Summarize git log by contributor
    """
    try:
        cmd_parts = ["shortlog"]
        
        # Add options
        if numbered:
            cmd_parts.append("-n")  # Sort by number of commits
        
        if summary:
            cmd_parts.append("-s")  # Suppress commit descriptions
        
        if email:
            cmd_parts.append("-e")  # Show emails
        
        # Add revision range if provided
        if revision_range:
            cmd_parts.append(revision_range)
        
        output = repo.git.execute(cmd_parts)
        
        if output:
            # Add summary statistics
            lines = output.strip().split('\n')
            total_commits = 0
            contributor_count = len(lines)
            
            for line in lines:
                # Extract commit count from numbered output
                if numbered and summary:
                    parts = line.strip().split(None, 1)
                    if parts and parts[0].isdigit():
                        total_commits += int(parts[0])
            
            result = f"Contributor Summary"
            if revision_range:
                result += f" ({revision_range})"
            result += f":\n\n{output}\n\n"
            
            if total_commits > 0:
                result += f"Total: {contributor_count} contributor(s), {total_commits} commit(s)"
            else:
                result += f"Total: {contributor_count} contributor(s)"
            
            return result
        else:
            return "No commits found in the specified range"
            
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "bad revision" in error_str:
            return f"Invalid revision range: {revision_range}"
        elif "unknown revision" in error_str:
            return f"Unknown revision in range: {revision_range}"
        else:
            return f"Shortlog error: {error_str}"
    except Exception as e:
        return f"Unexpected error during shortlog: {str(e)}"

def git_mv(repo: git.Repo, source: str, destination: str) -> str:
    """
    Move or rename a file, directory, or symlink
    """
    try:
        # Use git mv command
        output = repo.git.mv(source, destination)
        return f"Moved '{source}' to '{destination}'"
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "bad source" in error_str:
            return f"Source file not found: {source}"
        elif "can not move directory" in error_str:
            return f"Cannot move directory: {error_str}"
        elif "destination exists" in error_str:
            return f"Destination already exists: {destination}"
        elif "not under version control" in error_str:
            return f"File not under version control: {source}"
        else:
            return f"Git mv error: {error_str}"
    except Exception as e:
        return f"Unexpected error during git mv: {str(e)}"

def git_rm(repo: git.Repo, files: list[str], cached: bool = False, force: bool = False, recursive: bool = False) -> str:
    """
    Remove files from the working tree and from the index
    """
    try:
        # Build command flags
        cmd_parts = []
        if cached:
            cmd_parts.append("--cached")  # Remove from index only
        if force:
            cmd_parts.append("--force")  # Override up-to-date check
        if recursive:
            cmd_parts.append("-r")  # Remove directories recursively
        
        # Add files to remove
        cmd_parts.extend(files)
        
        # Execute git rm
        output = repo.git.rm(*cmd_parts)
        
        # Format result message
        if cached:
            action = "removed from index"
        else:
            action = "removed"
        
        if len(files) == 1:
            return f"Successfully {action}: {files[0]}"
        else:
            return f"Successfully {action} {len(files)} files"
            
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "did not match any files" in error_str:
            return f"No files matched the specified patterns"
        elif "not removing" in error_str and "file has local modifications" in error_str:
            return f"Cannot remove files with local modifications. Use force=true to override"
        elif "not removing" in error_str and "file has staged content" in error_str:
            return f"Cannot remove files with staged changes. Use force=true to override"
        else:
            return f"Git rm error: {error_str}"
    except Exception as e:
        return f"Unexpected error during git rm: {str(e)}"

def git_restore(repo: git.Repo, files: list[str], source: str | None = None, staged: bool = False, worktree: bool = True) -> str:
    """
    Restore working tree files
    """
    try:
        # Build command parts
        cmd_parts = ["restore"]
        
        # Add source if specified
        if source:
            cmd_parts.extend(["--source", source])
        
        # Handle staged/worktree options
        if staged and worktree:
            cmd_parts.append("--staged")
            cmd_parts.append("--worktree")
        elif staged:
            cmd_parts.append("--staged")
        # worktree is default, no flag needed unless both are specified
        
        # Add files
        cmd_parts.extend(files)
        
        # Execute git restore
        output = repo.git.execute(cmd_parts)
        
        # Format result message
        if len(files) == 1:
            location = "staged version" if staged and not worktree else "working tree"
            return f"Restored {files[0]} in {location}"
        else:
            location = "staged version" if staged and not worktree else "working tree"
            return f"Restored {len(files)} files in {location}"
            
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "pathspec" in error_str and "did not match" in error_str:
            return f"No files matched the specified patterns"
        elif "invalid reference" in error_str:
            return f"Invalid source reference: {source}"
        else:
            return f"Git restore error: {error_str}"
    except Exception as e:
        return f"Unexpected error during git restore: {str(e)}"

def git_tag(repo: git.Repo, action: str = "create", tag_name: str | None = None, 
           message: str | None = None, ref: str | None = None, 
           force: bool = False, annotated: bool = True, pattern: str | None = None) -> str:
    """
    Create, list, delete or verify tags
    """
    try:
        if action == "list":
            # List tags with optional pattern
            if pattern:
                output = repo.git.tag("-l", pattern)
            else:
                output = repo.git.tag("-l")
            
            if output:
                tags = output.strip().split('\n')
                return f"Tags ({len(tags)}):\n" + "\n".join(f"  - {tag}" for tag in tags)
            else:
                return "No tags found"
                
        elif action == "create":
            if not tag_name:
                return "Error: tag_name required for create action"
            
            cmd_parts = []
            
            if annotated and message:
                cmd_parts.extend(["-a", tag_name, "-m", message])
            elif annotated:
                # Annotated tag without message will open editor, which we can't handle
                return "Error: annotated tags require a message"
            else:
                # Lightweight tag
                cmd_parts.append(tag_name)
            
            if force:
                cmd_parts.append("-f")
                
            if ref:
                cmd_parts.append(ref)
            
            output = repo.git.tag(*cmd_parts)
            
            tag_type = "annotated" if annotated else "lightweight"
            return f"Created {tag_type} tag '{tag_name}'" + (f" at {ref}" if ref else "")
            
        elif action == "delete":
            if not tag_name:
                return "Error: tag_name required for delete action"
            
            output = repo.git.tag("-d", tag_name)
            return f"Deleted tag '{tag_name}'"
            
        elif action == "verify":
            if not tag_name:
                return "Error: tag_name required for verify action"
            
            try:
                output = repo.git.tag("-v", tag_name)
                return f"Tag '{tag_name}' verification:\n{output}"
            except git.GitCommandError as e:
                if "cannot verify a non-tag object" in str(e):
                    return f"Tag '{tag_name}' is not a signed tag"
                raise
                
        else:
            return f"Unknown tag action: {action}. Valid actions: list, create, delete, verify"
            
    except git.GitCommandError as e:
        error_str = str(e)
        
        if "already exists" in error_str:
            return f"Tag '{tag_name}' already exists. Use force=true to replace"
        elif "not found" in error_str:
            return f"Tag '{tag_name}' not found"
        else:
            return f"Git tag error: {error_str}"
    except Exception as e:
        return f"Unexpected error during git tag: {str(e)}"

def git_branch(repo: git.Repo, action: str = "list", all: bool = False, 
               remotes: bool = False, pattern: str | None = None) -> str:
    """
    List branches (create/delete operations are handled by separate tools)
    """
    try:
        if action != "list":
            return f"Only 'list' action is supported. Use git_create_branch or git_branch_delete for other operations"
        
        # Build command parts for listing
        cmd_parts = []
        
        if all:
            cmd_parts.append("-a")  # List all branches (local and remote)
        elif remotes:
            cmd_parts.append("-r")  # List remote branches only
        
        # Add pattern if specified
        if pattern:
            cmd_parts.append(pattern)
        
        # Execute git branch
        output = repo.git.branch(*cmd_parts)
        
        if output:
            # Parse output and format nicely
            lines = output.strip().split('\n')
            branches = []
            current_branch = None
            
            for line in lines:
                line = line.strip()
                if line.startswith('* '):
                    current_branch = line[2:]
                    branches.append(f"* {current_branch} (current)")
                else:
                    branches.append(f"  {line}")
            
            branch_type = "all" if all else "remote" if remotes else "local"
            result = f"Branches ({branch_type}):\n"
            result += "\n".join(branches)
            return result
        else:
            return "No branches found"
            
    except git.GitCommandError as e:
        return f"Git branch error: {str(e)}"
    except Exception as e:
        return f"Unexpected error during git branch: {str(e)}"

async def serve(repository: Path | None, read_only: bool = False) -> None:
    logger = logging.getLogger(__name__)

    if repository is not None:
        try:
            git.Repo(repository)
            logger.info(f"Using repository at {repository}")
        except git.InvalidGitRepositoryError:
            logger.error(f"{repository} is not a valid Git repository")
            return

    server_name = "mcp-git-read" if read_only else "mcp-git"
    server = Server(server_name)

    @server.list_tools()
    async def list_tools() -> list[Tool]:
        tools = []
        
        # Determine which tools to include based on read_only mode
        if read_only:
            allowed_tools = READ_ONLY_TOOLS | {"git_batch"}  # git_batch is allowed but validated
        else:
            allowed_tools = set(TOOL_REGISTRY.keys())  # All tools in write mode
        
        # Build tool list from registry
        for tool_name, (model_class, description) in TOOL_REGISTRY.items():
            if tool_name in allowed_tools:
                # Special case descriptions for read-only mode
                if read_only and tool_name == "git_remote":
                    description = "List remote repositories (read-only: list action only)"
                elif read_only and tool_name == "git_branch_delete":
                    description = "Delete local branches only (read-only: remote deletion blocked)"
                elif read_only and tool_name == "git_batch":
                    description = "Execute multiple git commands in sequence (read-only: limited to safe operations)"
                    
                tools.append(Tool(
                    name=tool_name,
                    description=description,
                    inputSchema=model_class.schema(),
                ))
        
        return tools

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
        # Check if tool is allowed in read-only mode
        if read_only:
            # Special handling for tools with restrictions
            if name == GitTools.REMOTE:
                if arguments.get("action") != "list":
                    error_msg = f"Tool '{name}' with action '{arguments.get('action')}' is not allowed in read-only mode"
                    log_tool_error("atxtechbro-git-mcp-server", name, error_msg, arguments.get("repo_path"), arguments)
                    return [TextContent(type="text", text=f"Error: {error_msg}")]
            elif name == GitTools.BRANCH_DELETE:
                if arguments.get("remote", False):
                    error_msg = "Remote branch deletion is not allowed in read-only mode"
                    log_tool_error("atxtechbro-git-mcp-server", name, error_msg, arguments.get("repo_path"), arguments)
                    return [TextContent(type="text", text=f"Error: {error_msg}")]
            elif name == GitTools.BATCH:
                # Validate all commands in batch are allowed
                for cmd in arguments.get("commands", []):
                    tool_name = cmd.get("tool")
                    if tool_name not in READ_ONLY_TOOLS and tool_name != GitTools.BATCH:
                        error_msg = f"Tool '{tool_name}' in batch is not allowed in read-only mode"
                        log_tool_error("atxtechbro-git-mcp-server", name, error_msg, arguments.get("repo_path"), arguments)
                        return [TextContent(type="text", text=f"Error: {error_msg}")]
                    # Recursively check restrictions for special tools
                    if tool_name == GitTools.REMOTE and cmd.get("args", {}).get("action") != "list":
                        error_msg = f"Remote action '{cmd.get('args', {}).get('action')}' in batch is not allowed in read-only mode"
                        log_tool_error("atxtechbro-git-mcp-server", name, error_msg, arguments.get("repo_path"), arguments)
                        return [TextContent(type="text", text=f"Error: {error_msg}")]
                    if tool_name == GitTools.BRANCH_DELETE and cmd.get("args", {}).get("remote", False):
                        error_msg = "Remote branch deletion in batch is not allowed in read-only mode"
                        log_tool_error("atxtechbro-git-mcp-server", name, error_msg, arguments.get("repo_path"), arguments)
                        return [TextContent(type="text", text=f"Error: {error_msg}")]
            elif name not in READ_ONLY_TOOLS:
                error_msg = f"Tool '{name}' is not allowed in read-only mode"
                log_tool_error("atxtechbro-git-mcp-server", name, error_msg, arguments.get("repo_path"), arguments)
                return [TextContent(type="text", text=f"Error: {error_msg}")]
        
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

                case GitTools.PULL:
                    result = git_pull(
                        repo,
                        arguments.get("remote", "origin"),
                        arguments.get("branch"),
                        arguments.get("rebase", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Pulled from {arguments.get('remote', 'origin')}", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Fetched from {arguments.get('remote', 'origin')}", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Merged branch {arguments['branch']}", repo_path, arguments)
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

                case GitTools.BATCH:
                    results = git_batch(repo, arguments["commands"])
                    success_count = sum(1 for r in results if r["status"] == "success")
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Batch executed: {success_count}/{len(results)} succeeded", repo_path, arguments)
                    
                    # Format results for display
                    formatted_results = []
                    for r in results:
                        if r["status"] == "success":
                            formatted_results.append(f"✓ {r['tool']}: {r['result']}")
                        else:
                            formatted_results.append(f"✗ {r['tool']}: {r['error']}")
                    
                    return [TextContent(
                        type="text",
                        text="\n".join(formatted_results)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, "Rebase operation completed", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, "Stash operation completed", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, "Stash pop completed", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, "Cherry-pick operation completed", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.REFLOG:
                    result = git_reflog(
                        repo,
                        arguments.get("max_count", 30),
                        arguments.get("ref")
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, "Retrieved reflog entries", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.BLAME:
                    result = git_blame(
                        repo,
                        arguments["file_path"],
                        arguments.get("line_range")
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Retrieved blame for {arguments['file_path']}", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, "Revert operation completed", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.RESET_HARD:
                    result = git_reset_hard(
                        repo,
                        arguments.get("ref", "HEAD")
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Hard reset to {arguments.get('ref', 'HEAD')}", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Deleted branch {arguments['branch_name']}", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, "Clean operation completed", repo_path, arguments)
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
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Bisect {arguments['action']} completed", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.DESCRIBE:
                    result = git_describe(
                        repo,
                        arguments.get("commit"),
                        arguments.get("tags", True),
                        arguments.get("all", False),
                        arguments.get("long", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, "Describe completed", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.SHORTLOG:
                    result = git_shortlog(
                        repo,
                        arguments.get("revision_range"),
                        arguments.get("numbered", True),
                        arguments.get("summary", True),
                        arguments.get("email", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, "Shortlog completed", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.MV:
                    result = git_mv(
                        repo,
                        arguments["source"],
                        arguments["destination"]
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Moved {arguments['source']} to {arguments['destination']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.RM:
                    result = git_rm(
                        repo,
                        arguments["files"],
                        arguments.get("cached", False),
                        arguments.get("force", False),
                        arguments.get("recursive", False)
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Removed {len(arguments['files'])} file(s)", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.RESTORE:
                    result = git_restore(
                        repo,
                        arguments["files"],
                        arguments.get("source"),
                        arguments.get("staged", False),
                        arguments.get("worktree", True)
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Restored {len(arguments['files'])} file(s)", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.TAG:
                    result = git_tag(
                        repo,
                        arguments.get("action", "create"),
                        arguments.get("tag_name"),
                        arguments.get("message"),
                        arguments.get("ref"),
                        arguments.get("force", False),
                        arguments.get("annotated", True),
                        arguments.get("pattern")
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, f"Tag action: {arguments.get('action', 'create')}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.BRANCH:
                    result = git_branch(
                        repo,
                        arguments.get("action", "list"),
                        arguments.get("all", False),
                        arguments.get("remotes", False),
                        arguments.get("pattern")
                    )
                    log_tool_success("atxtechbro-git-mcp-server", name, "Listed branches", repo_path, arguments)
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
