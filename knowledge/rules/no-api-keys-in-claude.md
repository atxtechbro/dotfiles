# No API Keys in Claude

Claude Pro/Max = OAuth only. No API keys. Stop looking.

**Won't work**: Setting ANTHROPIC_API_KEY, trying to find secret keys
**Will work**: Browser-based auth through `claude -p setup-token`

This isn't a config issue. It's how the product works.