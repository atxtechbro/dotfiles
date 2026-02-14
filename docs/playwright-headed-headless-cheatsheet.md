# Playwright MCP Headed vs Headless Cheat Sheet

Quick operational reference for AI-first CLI sessions.

## 60-Second Triage

1. Decide task mode:
   - Login/demo/visual verification -> `headed`
   - CI/batch/non-interactive -> `headless`
2. Check harness MCP config (not only shell env).
3. If `headed` on Linux, verify display prerequisites are present.
4. Restart harness session after config/env changes.
5. Validate with a minimal post-login authenticated-page check.

## Decision Table

| Situation | Mode |
|-----------|------|
| Login/MFA needed | Headed |
| Live demo or walkthrough | Headed |
| Visual bug investigation | Headed |
| CI or nightly automation | Headless |
| Fast non-interactive extraction | Headless |

## Top Failure Signatures

1. Missing display/X server launch errors
2. Browser does not appear despite headed intent
3. Transport/session closed unexpectedly
4. Login redirect succeeds but auth state is missing
5. Works once, fails after restart

## Fix Direction (One Line Each)

- Display/X errors -> Ensure headed prerequisites are passed in harness MCP env.
- No browser window -> Confirm harness is actually launching in headed mode.
- Transport closed -> Restart harness and re-launch MCP with validated config.
- Missing auth state -> Verify with authenticated route check after login.
- Restart regression -> Persist config in harness file, not temporary shell only.

## Canonical Runbook

Use full procedure for detailed diagnostics and recovery:
- `../knowledge/procedures/playwright-headed-vs-headless.md`

