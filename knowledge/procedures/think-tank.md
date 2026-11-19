# Think-Tank Directory

A designated space for personal content that lives outside the codebase but needs version control.

## Purpose
Store personal documents, notes, and drafts that:
- Don't belong in code directories
- Need to persist across development sessions
- Require version control for safety

## Location
**Always use**: `/think-tank/` in the main repository
**Never use**: Worktree locations (they're ephemeral)

## What Belongs Here
✓ Personal notes and brainstorming
✓ Resume drafts and career documents
✓ Learning notes and research
✓ Project ideas and planning docs
✓ Personal scripts or configurations

## What Doesn't Belong Here
✗ Code documentation (use `/docs/`)
✗ Project-specific notes (use project directories)
✗ Sensitive credentials (use `.bash_secrets`)
✗ Generated files or build artifacts

## Key Principle
Think-tank content is personal workspace material. It's tracked by git but kept separate from the technical ecosystem of the dotfiles.