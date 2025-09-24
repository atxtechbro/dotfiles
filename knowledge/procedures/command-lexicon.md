# Command Lexicon

Provider‑agnostic conventions for invoking procedures via natural language. This avoids provider‑specific slash commands while keeping commands predictable and easy to extend.

## Naming
- Use kebab‑case for command names (e.g., `close-issue`, `extract-best-frame`).
- A command maps to a procedure file named: `knowledge/procedures/<command>-procedure.md`.
- Alternative phrases are allowed (e.g., `close issue` for `close-issue`).

## Invocation Format
- Primary: `<command> <args>` (e.g., `close-issue 123`, `extract-best-frame /path/video.mp4`).
- Natural language: Phrases like “use the <command> procedure …” are acceptable and should be interpreted equivalently.
- Optional trailing context: Any text after the required arguments is treated as helpful guidance (constraints, preferences, hints) and incorporated with graceful flexibility.

## Parsing Rules
- Integers: Extract the first valid integer token after the command phrase for numeric IDs (e.g., issue numbers). If none is found or multiple integers appear without clear context, prompt the user to clarify.
- Quoted strings: Treat the first quoted string after the command as the primary string argument (e.g., a title or description) when relevant to the procedure. If absent, prompt interactively.
- Paths: Accept absolute or relative paths as arguments. If a path contains spaces, require quotes.

## Provider Behavior
- These conventions apply equally in Claude Code and OpenAI Codex, assuming the knowledge base is loaded.
- Procedures remain the single source of truth for the exact steps; this lexicon only defines how commands are recognized and parsed.

## Examples (non‑exhaustive)
- `close-issue 123` → `close-issue-procedure.md`
- `extract-best-frame "/videos/session.mp4"` → `extract-best-frame-procedure.md`

New commands work automatically when you add a corresponding `*-procedure.md` following these conventions; no changes to this file are required.
