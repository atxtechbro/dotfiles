# Context Window Token Limits

## Constraint Type
Physical - Model architecture limitation

## Description
Claude's context window is limited to 200,000 tokens total. This includes system prompts, conversation history, and file contents. This is a hard architectural limit of the model.

## Current Utilization
- ~25k tokens: Anthropic system prompts
- ~5k tokens: Knowledge directory baseline
- ~170k tokens: Available for conversation

## Impact on Five Focusing Steps
1. **Identify**: Monitor token usage throughout conversation
2. **Exploit**: Strategic use of remaining tokens
3. **Subordinate**: Design procedures to minimize token usage
4. **Elevate**: Cannot be elevated - fixed model limitation
5. **Repeat**: Must work within this constraint

## Mitigation Strategies
- Use `--resume` flag to continue conversations
- Fork conversations at decision points
- Prefer links over inline content when possible
- Strategic file reading (don't read unnecessarily)

## Measurement
Token counter in Claude Code CLI is authoritative.