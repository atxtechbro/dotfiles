# Claude Code AWS Bedrock Billing Incident - Company Note

## Date: 2025-01-28

## Incident Summary
Unexpected $37 AWS Bedrock charges despite having Claude Pro Max subscription ($200/month). Claude Code defaulted to AWS Bedrock on computer restart, causing additional Opus model charges.

## Root Cause
1. **Provider Persistence Failure**: Claude Code doesn't persistently remember provider preference (Claude Pro vs AWS Bedrock)
2. **Default Behavior**: On restart, Claude Code defaults to AWS Bedrock if AWS credentials are available
3. **Opaque Configuration**: Provider setting location is unclear and not well-documented
4. **Known Bug**: GitHub Issue #1676 confirms configuration persistence problems

## Current Workaround
```bash
cd ~/.claude
rm -rf credentials.json
# Open new terminal
claude
/login  # Re-authenticate with Claude Pro
```

## Permanent Solution Implemented

### 1. **Preventive Script** (`utils/prevent-bedrock-charges.sh`)
- Removes Bedrock environment variables
- Checks credentials for Bedrock configuration
- Adds shell protection to prevent Bedrock usage
- Creates safe wrapper script

### 2. **Shell Protection** (`.bash_aliases.d/claude-bedrock-protection.sh`)
- Auto-unsets Bedrock variables on shell startup
- Provides `claude-safe` alias
- Includes `claude-check-provider` diagnostic function
- Prevents accidental Bedrock activation

### 3. **Configuration Hardening**
- Added `"model": "opus"` to `.claude/settings.json`
- Environment variable `CLAUDE_CODE_NO_BEDROCK=1` (custom protection)
- Wrapper script ensures Claude Pro usage

## Lessons Learned

### Technical Insights
1. Claude Code uses `~/.claude/.credentials.json` for auth storage
2. No built-in mechanism to force Claude Pro over Bedrock
3. Provider preference isn't stored persistently
4. AWS SDK credential chain takes precedence when available

### Process Improvements
1. **Monitoring**: Set AWS billing alerts at lower thresholds
2. **Verification**: Always check `/status` after restart
3. **Documentation**: This incident becomes part of knowledge base
4. **Automation**: Shell protection prevents future incidents

## Action Items Completed
- [x] Research GitHub issues for similar problems
- [x] Check Anthropic documentation for configuration options
- [x] Audit AWS resources and usage
- [x] Implement permanent prevention solution
- [x] Document incident and solution

## Financial Impact
- Direct cost: $37 (AWS Bedrock charges)
- Learning value: Priceless - prevented future incidents
- Time invested: ~30 minutes resolution + documentation

## Prevention Measures
1. **Technical**: Automated shell protection
2. **Process**: Always verify provider after restart
3. **Monitoring**: AWS billing alerts
4. **Documentation**: This note + scripts in dotfiles

## Key Commands
```bash
# Check current provider
/status  # Look for "API Provider" line

# Safe launch
claude-safe  # Uses wrapper with protection

# Diagnostic check
claude-check-provider  # Verifies safe configuration

# Force re-authentication
rm ~/.claude/.credentials.json && claude && /login
```

## References
- GitHub Issue #1676: Persistent logout & configuration loss
- Anthropic Docs: `/settings` - Limited provider persistence options
- AWS Bedrock pricing: ~$0.015/1K input tokens for Opus

---

*"Not a waste of $37, but a learning experience we will use"* - Well said. This incident led to robust prevention measures that will save money and frustration in the future.