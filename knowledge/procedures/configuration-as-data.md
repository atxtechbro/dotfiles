# Configuration as Data

Prefer declarative JSON configuration over imperative scripts. Configuration should be data that describes the desired state, not code that achieves it.

## The Pattern
When faced with configuration needs:
1. First look for existing config files to extend
2. Add settings to existing structures (versioning mindset)
3. Use JSON/YAML over bash scripts
4. Keep additions minimal - often 3 lines beats 200

## Why This Matters
- **Readable**: JSON shows intent clearly
- **Versionable**: Git diffs on data are cleaner than code diffs
- **Portable**: Data works across platforms, scripts don't
- **Composable**: Easy to merge configurations
- **Tool-friendly**: IDEs, linters, and validators understand JSON

## Anti-pattern Example
```bash
# ❌ Don't create configure-claude-code-settings.sh
claude config set defaultMode acceptEdits
claude config set cleanupPeriodDays 90
```

## Preferred Pattern
```json
// ✅ Add to .claude/settings.json
{
  "defaultMode": "acceptEdits",
  "cleanupPeriodDays": 90
}
```

## Exception
Installation scripts that check for prerequisites and handle errors are appropriate. But even these should configure via data files, not embedded commands.

This approach aligns with infrastructure-as-code principles: declare what you want, let the system figure out how to achieve it.