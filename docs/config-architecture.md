# Agent Configuration Architecture

This document describes the configuration architecture for AI agents, implementing the **Config in Environment** principle from 12-Factor App methodology.

**See also:** [`knowledge/principles/config-in-environment.md`](../knowledge/principles/config-in-environment.md)

## Overview

The configuration layer enables agents to adapt to different users, preferences, and contexts without modifying code. It separates "what to do" (orchestration) from "how the user wants it done" (configuration).

## Architecture

```
┌─────────────────────────────────────┐
│   Orchestration Layer               │  ← What to do
│   (commands/*.md, procedures)        │     Generic agent logic
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Configuration Layer               │  ← What the user wants
│   (.agent-config.yml)                │     - User preferences
│                                       │     - Paths
│                                       │     - Workflows
│                                       │     - Personas
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Implementation Layer              │  ← How to achieve it
│   (LLM reasoning + tool execution)   │     Context-aware execution
└─────────────────────────────────────┘
```

## Configuration File

### Location

**Primary location:** `~/.config/agents/agent-config.yml` (XDG-compliant, portable)

**Alternative:** `.agent-config.yml` in dotfiles root (for development/testing)

**Symlink strategy:**
```bash
# Claude Code
ln -sf ~/.config/agents/agent-config.yml ~/.config/claude-code/.agent-config.yml

# Or in dotfiles
ln -sf ~/.config/agents/agent-config.yml $DOTFILES_ROOT/.agent-config.yml
```

### File Structure

```yaml
# User identity (shared across agents)
user:
  name: "Your Name"
  email: "your@email.com"
  github_username: "yourusername"
  persona:
    description: "Physical characteristics for visual tasks"
    photo_style: "professional"

# Agent-specific configurations
agents:
  agent-name:
    # Agent-specific settings
    setting_key: value

# Global settings
settings:
  debug: false
  validate_config: true
  allow_defaults: true
```

## Agent Integration Pattern

### 1. Define Config Schema

In `.agent-config.yml`, add your agent's section:

```yaml
agents:
  your-agent:
    # Required settings (agent fails if missing)
    required_setting: value

    # Optional settings (with documented defaults)
    optional_setting: value  # Default: some_value

    # Nested configuration
    subsection:
      nested_key: value
```

### 2. Load Configuration in Agent

At the beginning of your agent procedure (e.g., `commands/your-agent.md`):

```markdown
## Step 0: Load User Configuration

Load preferences from .agent-config.yml:

!# YAML config parser with nested key support
!CONFIG_FILE="${DOTFILES_ROOT:-.}/.agent-config.yml"
!
!# Function to extract nested YAML values
!# Supports paths like: "agents.your-agent.setting.nested"
!get_config() {
!  local path="$1"
!  local default="$2"
!
!  if [ ! -f "$CONFIG_FILE" ]; then
!    echo "$default"
!    return
!  fi
!
!  # Try Python with PyYAML for robust parsing (handles nested keys)
!  if command -v python3 &>/dev/null; then
!    python3 -c "
!import sys
!try:
!    import yaml
!    with open('$CONFIG_FILE') as f:
!        config = yaml.safe_load(f) or {}
!
!    # Navigate nested path
!    value = config
!    for key in '$path'.split('.'):
!        if isinstance(value, dict) and key in value:
!            value = value[key]
!        else:
!            print('$default')
!            sys.exit(0)
!
!    # Variable substitution for \${HOME} and \${user.*}
!    if isinstance(value, str):
!        import os
!        result = value.replace('\${HOME}', os.path.expanduser('~'))
!        if '\${user.' in result:
!            user = config.get('user', {})
!            result = result.replace('\${user.github_username}', user.get('github_username', ''))
!            # Add other substitutions as needed
!        print(result)
!    else:
!        print(value)
!except ImportError:
!    sys.exit(1)  # PyYAML not available
!except Exception:
!    print('$default')
!" 2>/dev/null && return
!  fi
!
!  # Fallback: simple grep for last key component
!  local simple_key="${path##*.}"
!  grep "^[[:space:]]*${simple_key}:" "$CONFIG_FILE" 2>/dev/null | \
!    sed 's/.*:[[:space:]]*//' | tr -d '"' || echo "$default"
!}
!
!# Load configuration with graceful defaults (use full nested paths)
!CONFIG_YOUR_SETTING=$(get_config "agents.your-agent.your_setting" "default_value")
!CONFIG_ANOTHER_SETTING=$(get_config "agents.your-agent.another_setting" "default")
!
!echo "📋 Configuration loaded:"
!echo "  Your setting: $CONFIG_YOUR_SETTING"
!echo "  Another setting: $CONFIG_ANOTHER_SETTING"
!echo ""

If config doesn't exist or PyYAML unavailable, defaults ensure agent still works.
```

**Key improvements:**
- Supports nested YAML paths (e.g., `agents.extract-best-frame.selection_criteria.optimize_for`)
- Handles variable substitution (`${HOME}`, `${user.github_username}`)
- Falls back to simple grep if Python/PyYAML unavailable
- Graceful degradation at multiple levels

### 3. Use Config in Agent Logic

Inject configuration variables into agent prompts and decisions:

```markdown
## Step 3: Execute Task

Based on user's configured preference for **${CONFIG_YOUR_SETTING}**:

- Behavior adapted to ${CONFIG_YOUR_SETTING} mode
- Using ${CONFIG_ANOTHER_SETTING} approach
- Target: ${CONFIG_TARGET_VALUE}

!echo "Executing with '${CONFIG_YOUR_SETTING}' configuration..."
```

### 4. Graceful Degradation

**Always provide sensible defaults:**

```bash
# Good: Falls back to default if config missing
CONFIG_MODE=${CONFIG_MODE:-auto}
CONFIG_OUTPUT_DIR=${CONFIG_OUTPUT_DIR:-./output}

# Bad: Fails if config missing
CONFIG_MODE=$CONFIG_MODE  # Will be empty if not set
```

**Document defaults in agent description:**

```markdown
# Your Agent
#
# Configuration (from .agent-config.yml):
# - mode: Execution mode (default: "auto")
# - output_dir: Where to save results (default: "./output")
# - enable_feature: Enable advanced feature (default: false)
```

## Examples

### Extract-Best-Frame

**Config:**
```yaml
agents:
  extract-best-frame:
    selection_criteria:
      optimize_for: "professional"  # vs "flattering", "candid"
      factors:
        - "neutral_expression"
        - "direct_eye_contact"
        - "business_attire"
      target_person: "${user.persona.description}"
```

**Usage in Agent:**
```markdown
### Round 1: Selection

Comparing frames based on **${CONFIG_OPTIMIZE_FOR}** criteria:
- Target person: ${CONFIG_TARGET_PERSON}
- Evaluation factors: ${CONFIG_FACTORS[@]}
```

### MakeResume

**Config:**
```yaml
agents:
  make-resume:
    paths:
      base_resume: "${HOME}/career/resume.md"
      output_dir: "${HOME}/career/resumes"
    data_sources:
      public_repos:
        owner: "${user.github_username}"
        rate_limit_delay: 7
```

**Usage in Agent:**
```markdown
## Step 1: Load Resume Base

!BASE_RESUME=$(get_config "base_resume" "${HOME}/resume.md")
!OUTPUT_DIR=$(get_config "output_dir" "./resumes")
!GITHUB_USER=$(get_config "owner" "${USER}")

Read base resume from: ${BASE_RESUME}
Will save to: ${OUTPUT_DIR}/${RESUME_DATE}-${COMPANY}-${ROLE}.md
```

### CloseIssue

**Config:**
```yaml
agents:
  close-issue:
    git:
      branch_naming: "issue-${issue_number}-${slug}"
      worktree_base: "${HOME}/worktrees"
    workflow:
      auto_label: true
      require_tests: true
```

**Usage in Agent:**
```markdown
## Step 2: Create Worktree

!BRANCH_FORMAT=$(get_config "branch_naming" "issue-${issue_number}")
!WORKTREE_BASE=$(get_config "worktree_base" "./worktrees")
!BRANCH_NAME=$(echo "$BRANCH_FORMAT" | envsubst)

Creating branch: ${BRANCH_NAME}
In worktree: ${WORKTREE_BASE}/${BRANCH_NAME}
```

## Configuration Schema Documentation

### User Section

Global user identity shared across all agents:

```yaml
user:
  name: string              # Full name
  email: string             # Email address
  phone: string             # Phone number (optional)
  location: string          # City, State/Country
  github_username: string   # GitHub username for PR searches
  linkedin_username: string # LinkedIn profile (optional)

  persona:                  # For visual/personal AI tasks
    description: string     # Physical characteristics
    photo_style: string     # preferred style: professional/casual/artistic
```

### Agent Sections

Each agent defines its own schema under `agents.agent-name`:

**Common patterns:**

```yaml
agents:
  agent-name:
    # Paths (use ${HOME} or ${DOTFILES_ROOT} for portability)
    paths:
      input_dir: string
      output_dir: string
      cache_dir: string

    # Preferences
    preferences:
      mode: enum            # Limited set of values
      enable_feature: bool
      threshold: number

    # Workflows
    workflow:
      auto_action: bool
      require_validation: bool
      commit_style: enum
```

## Variable Substitution

Config values support basic variable substitution:

```yaml
# Environment variables
home_dir: "${HOME}"
user_dir: "${HOME}/Documents"

# User-defined variables (from earlier in config)
github_user: "${user.github_username}"
repo_path: "${HOME}/repos/${user.github_username}"

# Dotfiles root
knowledge_path: "${DOTFILES_ROOT}/knowledge"
```

**In bash scripts:**
```bash
# Use envsubst for substitution
CONFIG_VALUE=$(get_config "some_path" "/default/path")
EXPANDED_PATH=$(echo "$CONFIG_VALUE" | envsubst)
```

## Validation

### Setup-Time Validation

In `setup.sh`, validate config on installation:

```bash
# Check if config exists
if [ ! -f ~/.config/agents/agent-config.yml ]; then
  echo "⚠️  No agent config found. Creating from example..."
  mkdir -p ~/.config/agents
  cp .agent-config.example.yml ~/.config/agents/agent-config.yml
  echo "📝 Edit ~/.config/agents/agent-config.yml with your preferences"
fi

# Validate required fields
validate_config() {
  local config_file="$1"

  # Check for required user fields
  if ! grep -q "github_username:" "$config_file"; then
    echo "❌ Missing required field: user.github_username"
    return 1
  fi

  echo "✅ Config validation passed"
}

validate_config ~/.config/agents/agent-config.yml
```

### Runtime Validation

In agent procedures:

```bash
# Validate critical config before proceeding
if [ -z "$CONFIG_GITHUB_USER" ]; then
  echo "❌ Error: github_username not configured"
  echo "   Edit .agent-config.yml and set user.github_username"
  exit 1
fi
```

## Migration Path

### For Existing Agents

1. **Identify hard-coded config:**
   - Grep for literal values (paths, names, preferences)
   - Look for assumptions (branch naming, file locations)

2. **Extract to config:**
   ```yaml
   agents:
     existing-agent:
       # Move hard-coded values here
       setting: "previously hard-coded value"
   ```

3. **Update agent to read config:**
   ```bash
   # Before (hard-coded)
   SETTING="hard-coded-value"

   # After (configurable)
   SETTING=$(get_config "setting" "hard-coded-value")
   ```

4. **Test with different configs:**
   - Try multiple values for each setting
   - Ensure defaults work when config missing

### For New Agents

1. Start with config in mind
2. Add agent section to `.agent-config.example.yml`
3. Document all config options in agent header
4. Use `get_config` from the start

## Best Practices

### DO:
- ✅ Provide sensible defaults for all config values
- ✅ Document config schema in `.agent-config.example.yml`
- ✅ Use ${HOME} and ${DOTFILES_ROOT} for portability
- ✅ Validate critical config at runtime
- ✅ Echo loaded config values for transparency
- ✅ Support both config file and env var overrides

### DON'T:
- ❌ Hard-code personal data (names, emails, paths)
- ❌ Fail silently if config is missing (use defaults)
- ❌ Require config for simple/optional features
- ❌ Expose secrets in config file (use env vars instead)
- ❌ Commit .agent-config.yml (only commit .example)

## Security Considerations

### Secrets Management

**Never store secrets in .agent-config.yml!**

```yaml
# ❌ BAD: Secrets in config
github:
  api_token: "ghp_abc123..."  # DON'T DO THIS

# ✅ GOOD: Reference env vars
github:
  api_token: "${GITHUB_TOKEN}"  # Read from environment
```

**In agent code:**
```bash
# Read from environment, not config
GITHUB_TOKEN=${GITHUB_TOKEN}
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Set GITHUB_TOKEN environment variable"
  exit 1
fi
```

### File Permissions

```bash
# Protect config file (contains personal data)
chmod 600 ~/.config/agents/agent-config.yml

# In setup.sh
if [ -f ~/.config/agents/agent-config.yml ]; then
  chmod 600 ~/.config/agents/agent-config.yml
fi
```

## Troubleshooting

### Config Not Loading

```bash
# Debug config loading
CONFIG_FILE="${DOTFILES_ROOT:-.}/.agent-config.yml"
echo "Looking for config at: $CONFIG_FILE"
if [ -f "$CONFIG_FILE" ]; then
  echo "✓ Config found"
  cat "$CONFIG_FILE" | head -20
else
  echo "✗ Config not found, using defaults"
fi
```

### Variable Substitution Not Working

```bash
# Use envsubst for complex substitution
CONFIG_VALUE=$(get_config "path" "/default")
EXPANDED=$(echo "$CONFIG_VALUE" | envsubst)
echo "Raw: $CONFIG_VALUE"
echo "Expanded: $EXPANDED"
```

### Config Value Not Applied

```bash
# Add debug logging
echo "DEBUG: CONFIG_SETTING='$CONFIG_SETTING'"
echo "DEBUG: Using value: ${CONFIG_SETTING:-default}"
```

## Future Enhancements

### Potential Improvements

1. **JSON Schema validation:**
   - Define schema for .agent-config.yml
   - Validate on setup and runtime
   - Generate docs from schema

2. **Config inheritance:**
   - Global defaults → User config → Repo config → Env vars
   - Precedence chain for overrides

3. **Config UI:**
   - Interactive setup wizard
   - Config validation with helpful errors
   - Template generation for new agents

4. **Multi-environment support:**
   - Different configs for work vs personal
   - Profile switching: `claude --config=work`

5. **Config encryption:**
   - Encrypt sensitive sections
   - Decrypt on demand with passphrase

## See Also

- [Config in Environment Principle](../knowledge/principles/config-in-environment.md)
- [AI Harness Agnosticism](../knowledge/principles/ai-harness-agnosticism.md)
- [Extract-Best-Frame Example](../commands/extract-best-frame.md)
- [12-Factor App: Config](https://12factor.net/config)

---

**Status:** ✅ Implemented for Extract-Best-Frame (tracer bullet)

**Next Steps:**
1. Apply pattern to MakeResume
2. Apply pattern to CloseIssue
3. Standardize config loading function
4. Create validation helpers
