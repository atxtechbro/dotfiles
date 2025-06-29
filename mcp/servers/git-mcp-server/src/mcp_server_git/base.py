"""Base functionality shared between git-read and git-write MCP servers."""
import git
from pydantic import BaseModel
from enum import Enum

# Pydantic models for all git operations
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
    """Enum of all git tools for type safety"""
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

# Lists of tools by category
READ_ONLY_TOOLS = [
    GitTools.STATUS,
    GitTools.DIFF_UNSTAGED,
    GitTools.DIFF_STAGED,
    GitTools.DIFF,
    GitTools.LOG,
    GitTools.SHOW,
    GitTools.WORKTREE_LIST,
    GitTools.REFLOG,
    GitTools.BLAME,
    GitTools.DESCRIBE,
    GitTools.SHORTLOG,
]

WRITE_TOOLS = [
    GitTools.COMMIT,
    GitTools.ADD,
    GitTools.RESET,
    GitTools.CREATE_BRANCH,
    GitTools.CHECKOUT,
    GitTools.WORKTREE_ADD,
    GitTools.WORKTREE_REMOVE,
    GitTools.PUSH,
    GitTools.PULL,
    GitTools.FETCH,
    GitTools.MERGE,
    GitTools.REBASE,
    GitTools.STASH,
    GitTools.STASH_POP,
    GitTools.CHERRY_PICK,
    GitTools.REVERT,
    GitTools.RESET_HARD,
    GitTools.BRANCH_DELETE,
    GitTools.CLEAN,
    GitTools.BISECT,
]

# Special tools that exist in both servers
SHARED_TOOLS = [
    GitTools.REMOTE,  # list action is read-only, others are write
    GitTools.BATCH,   # can execute both read and write commands
]

# Implementation functions for all git operations
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
        output.append(f"\n--- {d.a_path}\n+++ {d.b_path}\n{d.diff.decode('utf-8', errors='replace')}")
    return "".join(output)

def git_worktree_add(repo: git.Repo, worktree_path: str, branch_name: str | None = None, 
                     create_branch: bool = False) -> str:
    cmd_parts = ["worktree", "add", worktree_path]
    
    if create_branch and branch_name:
        cmd_parts.extend(["-b", branch_name])
    elif branch_name:
        cmd_parts.append(branch_name)
    
    output = repo.git.execute(cmd_parts)
    return f"Worktree added at {worktree_path}" + (f" on new branch {branch_name}" if create_branch and branch_name else "")

def git_worktree_remove(repo: git.Repo, worktree_path: str, force: bool = False) -> str:
    cmd_parts = ["worktree", "remove", worktree_path]
    if force:
        cmd_parts.insert(2, "--force")
    
    output = repo.git.execute(cmd_parts)
    return f"Worktree at {worktree_path} removed"

def git_worktree_list(repo: git.Repo) -> str:
    output = repo.git.worktree("list", "--porcelain")
    
    worktrees = []
    current_wt = {}
    
    for line in output.strip().split('\n'):
        if not line:
            if current_wt:
                worktrees.append(current_wt)
                current_wt = {}
            continue
            
        if line.startswith("worktree "):
            current_wt["path"] = line[9:]
        elif line.startswith("HEAD "):
            current_wt["head"] = line[5:]
        elif line.startswith("branch "):
            current_wt["branch"] = line[7:]
        elif line.startswith("detached"):
            current_wt["detached"] = True
    
    if current_wt:
        worktrees.append(current_wt)
    
    if not worktrees:
        return "No worktrees found"
    
    result = []
    for wt in worktrees:
        status = []
        status.append(f"Path: {wt.get('path', 'unknown')}")
        if wt.get("branch"):
            status.append(f"Branch: {wt['branch']}")
        elif wt.get("detached"):
            status.append(f"HEAD detached at {wt.get('head', 'unknown')[:7]}")
        else:
            status.append(f"HEAD: {wt.get('head', 'unknown')[:7]}")
        result.append("\n".join(status))
    
    return "\n\n".join(result)

def git_push(repo: git.Repo, remote: str = "origin", branch: str = "", 
             set_upstream: bool = False, force: bool = False) -> str:
    # Safety check: prevent pushing to main/master by default
    if branch.lower() in ["main", "master"]:
        return "Error: Direct push to main/master branch is not allowed. Please create a feature branch and pull request."
    
    cmd_parts = ["push", remote]
    
    if set_upstream:
        cmd_parts.append("--set-upstream")
    
    if force:
        cmd_parts.append("--force")
    
    cmd_parts.append(branch)
    
    try:
        output = repo.git.execute(cmd_parts)
        return output if output else f"Successfully pushed to {remote}/{branch}"
    except git.GitCommandError as e:
        if "non-fast-forward" in str(e):
            return f"Push rejected: non-fast-forward. Pull changes first or use force=True if you're sure.\n{str(e)}"
        elif "no upstream branch" in str(e):
            return f"No upstream branch. Use set_upstream=True to set it.\n{str(e)}"
        else:
            return f"Push failed: {str(e)}"

def git_pull(repo: git.Repo, remote: str = "origin", branch: str | None = None, 
             rebase: bool = False) -> str:
    cmd_parts = ["pull", remote]
    
    if rebase:
        cmd_parts.append("--rebase")
    
    if branch:
        cmd_parts.append(branch)
    
    try:
        output = repo.git.execute(cmd_parts)
        return output if output else "Already up to date"
    except git.GitCommandError as e:
        if "conflict" in str(e).lower():
            return f"Pull failed due to conflicts. Resolve conflicts and commit.\n{str(e)}"
        else:
            return f"Pull failed: {str(e)}"

def git_merge(repo: git.Repo, branch: str, message: str | None = None, 
              strategy: str | None = None, abort: bool = False) -> str:
    if abort:
        try:
            output = repo.git.merge("--abort")
            return "Merge aborted successfully"
        except git.GitCommandError as e:
            return f"Failed to abort merge: {str(e)}"
    
    cmd_parts = ["merge", branch]
    
    if message:
        cmd_parts.extend(["-m", message])
    
    if strategy == "ff-only":
        cmd_parts.append("--ff-only")
    elif strategy == "no-ff":
        cmd_parts.append("--no-ff")
    elif strategy == "squash":
        cmd_parts.append("--squash")
    
    try:
        output = repo.git.execute(cmd_parts)
        return output if output else f"Successfully merged '{branch}' into current branch"
    except git.GitCommandError as e:
        if "CONFLICT" in str(e):
            return f"Merge conflict detected. Resolve conflicts and commit, or run with abort=True to cancel.\n{str(e)}"
        elif "not something we can merge" in str(e):
            return f"Cannot merge: '{branch}' is not a valid branch or commit"
        else:
            return f"Merge failed: {str(e)}"

def git_remote(repo: git.Repo, action: str, name: str | None = None, url: str | None = None) -> str:
    if action == "list":
        remotes = repo.git.remote("-v")
        return remotes if remotes else "No remotes configured"
    
    elif action == "add":
        if not name or not url:
            return "Error: Both name and URL required for adding remote"
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

def git_batch(repo: git.Repo, commands: list[dict], allowed_tools: list[str] | None = None) -> list[dict]:
    """Execute multiple git commands in sequence
    
    Args:
        repo: Git repository
        commands: List of commands to execute
        allowed_tools: List of allowed tool names (for read/write separation)
    """
    results = []
    
    for cmd in commands:
        tool = cmd.get("tool")
        args = cmd.get("args", {})
        
        # Check if tool is allowed (for server separation)
        if allowed_tools and tool not in allowed_tools:
            results.append({
                "tool": tool, 
                "status": "error", 
                "error": f"Tool '{tool}' not allowed in this server"
            })
            continue
        
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
            elif tool == "git_diff_unstaged":
                result = git_diff_unstaged(repo)
            elif tool == "git_diff_staged":
                result = git_diff_staged(repo)
            elif tool == "git_diff":
                result = git_diff(repo, args.get("target"))
            elif tool == "git_log":
                result = git_log(repo, args.get("max_count", 10))
            elif tool == "git_show":
                result = git_show(repo, args.get("revision"))
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
            elif tool == "git_worktree_list":
                result = git_worktree_list(repo)
            elif tool == "git_worktree_add":
                result = git_worktree_add(repo, args.get("worktree_path"), args.get("branch_name"), args.get("create_branch", False))
            elif tool == "git_worktree_remove":
                result = git_worktree_remove(repo, args.get("worktree_path"), args.get("force", False))
            elif tool == "git_remote":
                result = git_remote(repo, args.get("action"), args.get("name"), args.get("url"))
            else:
                result = f"Unknown tool: {tool}"
            
            results.append({"tool": tool, "status": "success", "result": result})
        except Exception as e:
            results.append({"tool": tool, "status": "error", "error": str(e)})
            break  # Stop on first error
    
    return results

def git_fetch(repo: git.Repo, remote: str = "origin", branch: str | None = None,
              fetch_all: bool = False, prune: bool = False, tags: bool = True) -> str:
    cmd_parts = ["fetch"]
    
    if fetch_all:
        cmd_parts.append("--all")
    else:
        cmd_parts.append(remote)
        if branch:
            cmd_parts.append(branch)
    
    if prune:
        cmd_parts.append("--prune")
    
    if not tags:
        cmd_parts.append("--no-tags")
    
    try:
        output = repo.git.execute(cmd_parts)
        if not output:
            return "Fetch completed successfully"
        return output
    except git.GitCommandError as e:
        return f"Fetch failed: {str(e)}"

def git_rebase(repo: git.Repo, onto: str | None = None, interactive: bool = False, 
               continue_rebase: bool = False, skip: bool = False, abort: bool = False) -> str:
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
    """Apply and remove stashed changes"""
    cmd_parts = ["stash", "pop"]
    
    if index:
        cmd_parts.append("--index")
    
    if stash_ref:
        cmd_parts.append(stash_ref)
    
    try:
        output = repo.git.execute(cmd_parts)
        return output if output else "Applied and removed stash"
    except git.GitCommandError as e:
        if "conflict" in str(e).lower():
            return f"Stash pop failed due to conflicts. Resolve and commit.\n{str(e)}"
        elif "No stash entries found" in str(e):
            return "No stashes to pop"
        else:
            return f"Stash pop failed: {str(e)}"

def git_cherry_pick(repo: git.Repo, commits: list[str] | str, no_commit: bool = False,
                    continue_pick: bool = False, skip: bool = False, abort: bool = False,
                    mainline_parent: int | None = None) -> str:
    """Cherry-pick commits onto current branch"""
    
    # Handle cherry-pick control operations
    if abort:
        try:
            repo.git.cherry_pick("--abort")
            return "Cherry-pick aborted successfully"
        except git.GitCommandError as e:
            return f"Error aborting cherry-pick: {str(e)}"
    
    if continue_pick:
        try:
            repo.git.cherry_pick("--continue")
            return "Cherry-pick continued successfully"
        except git.GitCommandError as e:
            if "no cherry-pick in progress" in str(e).lower():
                return "No cherry-pick in progress"
            return f"Error continuing cherry-pick: {str(e)}"
    
    if skip:
        try:
            repo.git.cherry_pick("--skip")
            return "Skipped current commit and continued cherry-pick"
        except git.GitCommandError as e:
            if "no cherry-pick in progress" in str(e).lower():
                return "No cherry-pick in progress"
            return f"Error skipping commit: {str(e)}"
    
    # Start a new cherry-pick
    if isinstance(commits, str):
        commits = [commits]
    
    cmd_parts = ["cherry-pick"]
    
    if no_commit:
        cmd_parts.append("-n")
    
    if mainline_parent is not None:
        cmd_parts.extend(["-m", str(mainline_parent)])
    
    cmd_parts.extend(commits)
    
    try:
        output = repo.git.execute(cmd_parts)
        commit_word = "commit" if len(commits) == 1 else "commits"
        return output if output else f"Successfully cherry-picked {len(commits)} {commit_word}"
    except git.GitCommandError as e:
        if "conflict" in str(e).lower():
            return f"Cherry-pick conflict. Resolve and run with --continue, or --abort.\n{str(e)}"
        else:
            return f"Cherry-pick failed: {str(e)}"

def git_reflog(repo: git.Repo, max_count: int = 30, ref: str | None = None) -> str:
    """Show reference log for recovery and history inspection"""
    cmd_parts = ["reflog"]
    
    if ref:
        cmd_parts.append(ref)
    
    cmd_parts.extend(["-n", str(max_count)])
    
    try:
        output = repo.git.execute(cmd_parts)
        return output if output else "No reflog entries found"
    except git.GitCommandError as e:
        return f"Reflog error: {str(e)}"

def git_blame(repo: git.Repo, file_path: str, line_range: str | None = None) -> str:
    """Show who last modified each line of a file"""
    cmd_parts = ["blame"]
    
    if line_range:
        cmd_parts.extend(["-L", line_range])
    
    cmd_parts.append(file_path)
    
    try:
        output = repo.git.execute(cmd_parts)
        return output if output else f"No blame information for {file_path}"
    except git.GitCommandError as e:
        if "no such path" in str(e).lower():
            return f"File not found: {file_path}"
        else:
            return f"Blame error: {str(e)}"

def git_revert(repo: git.Repo, commits: list[str] | str, no_commit: bool = False, 
               no_edit: bool = False) -> str:
    """Create new commits that undo previous commits"""
    if isinstance(commits, str):
        commits = [commits]
    
    cmd_parts = ["revert"]
    
    if no_commit:
        cmd_parts.append("-n")
    
    if no_edit:
        cmd_parts.append("--no-edit")
    
    cmd_parts.extend(commits)
    
    try:
        output = repo.git.execute(cmd_parts)
        commit_word = "commit" if len(commits) == 1 else "commits"
        return output if output else f"Successfully reverted {len(commits)} {commit_word}"
    except git.GitCommandError as e:
        if "conflict" in str(e).lower():
            return f"Revert resulted in conflicts. Resolve and commit.\n{str(e)}"
        else:
            return f"Revert failed: {str(e)}"

def git_reset_hard(repo: git.Repo, ref: str = "HEAD") -> str:
    """Hard reset to a specific commit (DESTRUCTIVE)"""
    try:
        repo.git.reset("--hard", ref)
        return f"Hard reset to {ref} completed. All uncommitted changes were discarded."
    except git.GitCommandError as e:
        return f"Reset failed: {str(e)}"

def git_branch_delete(repo: git.Repo, branch_name: str, force: bool = False, 
                      remote: bool = False) -> str:
    """Delete local and optionally remote branches"""
    # Special handling for read-only server
    if remote and hasattr(repo, "_read_only_mode"):
        return "Error: Remote branch deletion not allowed in read-only mode"
    
    try:
        # Delete local branch
        if force:
            repo.git.branch("-D", branch_name)
        else:
            repo.git.branch("-d", branch_name)
        
        result = f"Deleted local branch '{branch_name}'"
        
        # Delete remote branch if requested
        if remote:
            try:
                # Push deletion to remote
                repo.git.push("origin", "--delete", branch_name)
                result += f"\nDeleted remote branch 'origin/{branch_name}'"
            except git.GitCommandError as e:
                result += f"\nFailed to delete remote branch: {str(e)}"
        
        return result
        
    except git.GitCommandError as e:
        if "not found" in str(e):
            return f"Branch '{branch_name}' not found"
        elif "not fully merged" in str(e):
            return f"Branch '{branch_name}' is not fully merged. Use force=True to delete anyway."
        else:
            return f"Failed to delete branch: {str(e)}"

def git_clean(repo: git.Repo, force: bool = False, directories: bool = False,
              ignored: bool = False, dry_run: bool = True) -> str:
    """Remove untracked files and directories (DESTRUCTIVE)"""
    try:
        cmd_parts = ["clean"]
        
        # Always include -n for dry run or -f for force
        if dry_run:
            cmd_parts.append("-n")  # Dry run
        elif force:
            cmd_parts.append("-f")  # Force deletion
        else:
            return "Error: force=True required to actually delete files (or use dry_run=True to preview)"
        
        # Additional flags
        flags = ""
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