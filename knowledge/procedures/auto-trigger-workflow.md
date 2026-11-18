# Retired Claude GitHub Automation

Claude automation in GitHub Actions has been retired. Adding the `claude` label or
posting an `@claude` mention no longer starts issue implementation or PR review.
Automatic issue triage has also been removed.

The retired workflows were:

- `.github/workflows/claude-implementation.yml`
- `.github/workflows/auto-trigger-claude.yml`
- `.github/workflows/auto-label-issues.yml`

Their prompt template and knowledge aggregation script were removed with them.
The remaining dotfiles validation workflows use explicit `contents: read`
permissions and check out the repository with `persist-credentials: false`.

Local development with Claude Code and the procedure in
[`commands/close-issue.md`](../../commands/close-issue.md) remains available.

## GitHub Cleanup

These settings and credentials live outside Git, so deleting workflow files does
not complete the cleanup:

1. Disable the three retired workflows and cancel any active runs. Disabling a
   workflow does not cancel runs that have already started.
2. Delete the Actions secrets `CLAUDE_CODE_OAUTH_TOKEN` and `CLAUDE_TRIGGER_PAT`,
   and remove the repository variable `CLAUDE_CODE_SUBSCRIPTION`.
3. Revoke the underlying GitHub personal access token and revoke or rotate the
   Claude credential in the respective accounts. Deleting an Actions secret
   removes its stored copy; it does not invalidate the credential. If a credential
   is shared with another integration, replace it there before revoking it.
4. Keep default Actions permissions read-only, and enable secret scanning and
   push protection for this public repository.
5. Review available workflow history and unexpected repository changes. Scan
   tracked files and Git history for credentials, and revoke any exposed secrets.

Do not restore the old workflows from Git history without a security review of
input handling, authorization, permissions, and credential use.
