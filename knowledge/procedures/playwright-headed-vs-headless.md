# Playwright MCP: Headed vs Headless

Cross-harness runbook for deterministic browser mode selection in AI-first CLI workflows.

## Why This Exists

In CLI harnesses, Playwright MCP mode can appear to "mysteriously" switch to headless because:
- Harness-level config differs from shell-level env.
- MCP subprocesses inherit only what the harness passes.
- Display stack prerequisites are missing even when config requests headed mode.

This runbook makes headed and headless behavior predictable across:
- Claude Code
- OpenAI Codex
- GitHub Copilot CLI

## Mode Selection

Choose `headed` when you need:
- Login and MFA flows.
- Live demos and walkthroughs.
- Visual verification of UI states.
- Debugging anti-bot/captcha interactions.

Choose `headless` when you need:
- CI or batch automation.
- Non-interactive extraction or checks.
- Faster, repeatable automation without UI.

## Common Failure Signatures

- Launch error about missing X server or `$DISPLAY`.
- Session dies with transport-closed style errors.
- Login appears successful but follow-up page is unauthenticated.
- Browser window never appears despite headed intent.

## Deterministic Diagnostics

Run this sequence in order:

1. Verify harness config source of truth.
   - Confirm the active config file for your harness and session.
2. Verify MCP subprocess environment.
   - Ensure headed prerequisites are passed in harness config env, not only in shell.
3. Verify display stack prerequisites.
   - Linux/X11: `DISPLAY` and `XAUTHORITY` must be valid for the session user.
   - Wayland environments may require Xwayland compatibility for specific setups.
4. Verify restart boundary.
   - If config changed, restart the harness session so MCP launches with new env.
5. Verify with a neutral authenticated-page check.
   - Confirm post-login access to a known authenticated route/view, not just a login redirect.

## Cross-Harness Notes

### Claude Code
- Keep MCP server config aligned with `mcp/mcp.json` and enabled server settings.
- If MCP env changes, restart the CLI session to relaunch subprocesses.

### OpenAI Codex
- Configure Playwright MCP env under `.codex/config.toml` `[mcp_servers.playwright]`.
- Treat shell exports as insufficient unless reflected in Codex MCP server env.

### GitHub Copilot CLI
- Use the CLI's MCP config/env mechanism as the runtime source of truth.
- Ensure session restarts occur after env/config updates.

## Recovery Playbook

Use smallest-safe-change-first:

1. Confirm intended mode for task (`headed` or `headless`).
2. Align harness MCP env to that mode.
3. Restart harness session.
4. Re-run minimal navigation check.
5. Re-run login or demo flow.
6. Validate with an authenticated-page check.

Stop and escalate when:
- Same failure repeats after two config-correct restarts.
- Mode appears correct but auth state is unstable across immediate retries.

## Definition Of Done

- Intended mode is explicitly confirmed by behavior.
- Target flow completes in that mode.
- Follow-up authenticated-page verification passes.
- Behavior remains stable after one full harness restart.

