# Command Lexicon

Provider-agnostic mapping from natural language commands to procedures. Enables using the same commands in Claude Code and OpenAI Codex without relying on provider-specific slash commands.

## close-issue
- Intent: Complete and implement a GitHub issue and open a PR that references the issue.
- Primary command: "close-issue <number>"
- Alternative formats: "close issue <number>" (without hyphen)
- Arguments:
  - <number>: GitHub issue number (parsing rule: extract the first valid integer token after the command phrase; if no integer is found or multiple integers appear without clear context, prompt the user to clarify the issue number)
- Variants:
  - "close issue 123"
  - "close-issue 123"
  - "use the close-issue procedure to close GitHub issue 123"
  - "please close issue #123"
- Procedure: [close-issue-procedure.md](close-issue-procedure.md)
- Provider notes:
  - Use absolute paths and follow the Git Worktree Workflow
  - Ensure PR title/body reference "Closes #<number>"
