# Command Lexicon

Provider-agnostic mapping from natural language commands to procedures. Enables using the same commands in Claude Code and OpenAI Codex without relying on provider-specific slash commands.

## close-issue
- Intent: Complete and implement a GitHub issue and open a PR that references the issue.
- Primary command: "close-issue <number>"
- Alternative formats: "close issue <number>" (without hyphen)
- Arguments:
  - <number>: GitHub issue number (parsing rule: extract the first valid integer token after the command phrase; if no integer is found or multiple integers appear without clear context, prompt the user to clarify the issue number)
- Optional natural‑language qualifiers:
  - Any trailing text after the issue number should be treated as additional context (constraints, preferences, hints) and incorporated with graceful flexibility.
- Variants:
  - "close issue 123"
  - "close-issue 123"
  - "use the close-issue procedure to close GitHub issue 123"
  - "please close issue #123"
- Procedure: [close-issue-procedure.md](close-issue-procedure.md)

## extract-best-frame
- Intent: Extract frames from a video and select the most flattering frame via tournament comparison.
- Primary command: "extract-best-frame <video_path> [<frames_dir>] [<output_dir>]"
- Alternative formats: "best-frame <video_path>"
- Arguments:
  - <video_path>: Path to the input video
  - <frames_dir> (optional): Directory to write extracted frames
  - <output_dir> (optional): Directory to save the selected best frame
- Optional natural‑language qualifiers:
  - Any trailing text after the video path (and optional dirs) should be treated as selection guidance (preferences, qualities to optimize for) and incorporated with graceful flexibility.
- Variants:
  - "extract best frame from <video_path>"
  - "best-frame <video_path>"
- Procedure: [extract-best-frame-procedure.md](extract-best-frame-procedure.md)
