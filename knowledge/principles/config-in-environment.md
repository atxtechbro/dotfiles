# Config in Environment

**12-Factor Principle III**: Store configuration in the environment, not hard-coded in code.

## Core Concept

Configuration that varies between users (paths, preferences, workflows) should be externalized. This enables the same agent to serve different users without forking code.

**In AI agents:** Users declare **what** they want (config), agents implement **how** to achieve it (code).

## The Problem

Hard-coded config blocks shareability:
- Can't publish agents with personal data
- Users can't personalize without editing code
- Creates vendor lock-in (harness-specific paths)

**Example:**
```bash
# ❌ Hard-coded (not shareable)
career/resumes/${RESUME_DATE}-company-name.md

# ✅ Configurable (shareable)
${config.paths.output_dir}/${RESUME_DATE}-${company}-${role}.md
```

## The Solution

**Three-layer architecture:**
```
Orchestration (commands/*.md)  ← WHAT to do (generic logic)
         ↓
Configuration (.agent-config.yml)  ← WHAT user wants (preferences)
         ↓
Implementation (LLM execution)  ← HOW to achieve it
```

**Config file (`.agent-config.yml`):**
```yaml
user:
  github_username: "yourusername"
  persona:
    description: "6'3\", hazel eyes"

agents:
  extract-best-frame:
    selection_criteria:
      optimize_for: "professional"  # vs "flattering", "candid"
      target_person: "${user.persona.description}"
```

**Agent reads config:**
```bash
CONFIG=$(get_config "agents.extract-best-frame.selection_criteria.optimize_for" "flattering")
```

## Benefits

- **Shareable** - No personal data in code
- **Personalizable** - Users edit YAML, not procedures
- **Portable** - Works across Claude/Cursor/Codex
- **Composable** - Mix agents with consistent config

## Implementation

**For agents:** Use `get_config()` helper for nested YAML paths with graceful defaults.

**For users:** Copy `.agent-config.example.yml` → `.agent-config.yml` and customize.

**Details:** See [`docs/config-architecture.md`](../../docs/config-architecture.md) for full implementation guide.

## Relationship to Other Principles

- **[AI Harness Agnosticism](ai-harness-agnosticism.md)** - Config enables portability
- **[Systems Stewardship](systems-stewardship.md)** - Config as single source of truth
- **[Subtraction Creates Value](subtraction-creates-value.md)** - Removes need to fork
- **[Developer Experience](developer-experience.md)** - YAML editing easier than code

## References

- [12-Factor App: Config](https://12factor.net/config)
- [Config Architecture Guide](../../docs/config-architecture.md)
