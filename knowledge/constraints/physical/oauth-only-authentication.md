# OAuth-Only Authentication for Claude Pro/Max

## Constraint Type
Physical - Product architecture decision

## Description
Claude Pro and Claude Max subscriptions use OAuth browser-based authentication exclusively. There are no API keys available for these tiers. This is a fundamental product design constraint.

## Impact on Five Focusing Steps
1. **Identify**: No API key = physical constraint, not configuration issue
2. **Exploit**: Use browser-based auth flow via `claude -p setup-token`
3. **Subordinate**: All automation must work within OAuth token lifecycle
4. **Elevate**: Cannot be elevated - product architecture decision
5. **Repeat**: Constraint is permanent for Pro/Max tiers

## Token Lifecycle
- Tokens obtained via browser OAuth flow
- Stored in `~/.claude/`
- Must be refreshed periodically
- Cannot be generated programmatically

## Common Misconceptions
- "Just set ANTHROPIC_API_KEY" - Does not work for Pro/Max
- "Find the API key in settings" - Does not exist
- "Use a different auth method" - None available