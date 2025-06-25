# Self-Organizing README

Procedure for maintaining README.md as an AI-first navigation index based on actual usage patterns.

## Concept
Instead of heroic one-off reorganizations, create a living system that keeps the README aligned with where work actually happens.

## Implementation Approach
1. Create a `.claude/commands/reorganize-readme.md` command
2. Command analyzes last 1000 commit messages (first line only)
3. Reorients README.md sections based on activity patterns
4. Run as GitHub Action daily for fast feedback loops
5. Creates PR for human review

## Benefits
- README reflects reality, not aspirations
- AI finds relevant sections faster when starting with 0/200k context
- Sections naturally bubble up/down based on actual use
- No manual maintenance required

## Future Enhancement
- Weight recent commits more heavily
- Consider file change frequency from git log
- Group related areas intelligently

This exemplifies systems thinking: automate the maintenance rather than heroically reorganizing.