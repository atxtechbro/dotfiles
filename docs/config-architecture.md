# Agent Configuration Architecture

Implementation guide for the [Config in Environment](../knowledge/principles/config-in-environment.md) principle.

## Quick Start

1. **Copy example:** `cp .agent-config.example.yml .agent-config.yml`
2. **Customize:** Edit user info, paths, preferences
3. **Use in agents:** Load with `get_config()` helper

## Configuration File

**Location:** `.agent-config.yml` (gitignored) or `~/.config/agents/agent-config.yml`

**Structure:**
```yaml
user:
  name: "Your Name"
  github_username: "yourusername"
  persona:
    description: "6'3\", hazel eyes"  # For visual tasks

agents:
  agent-name:
    setting: value
    nested:
      key: value
```

## Agent Integration Pattern

### Step 1: Define Schema

Add agent config to `.agent-config.example.yml`:
```yaml
agents:
  your-agent:
    your_setting: "default_value"
    paths:
      output_dir: "${HOME}/output"
```

### Step 2: Load in Agent

Use `get_config()` helper in agent procedure:

```bash
# YAML config parser with nested key support
CONFIG_FILE="${DOTFILES_ROOT:-.}/.agent-config.yml"

get_config() {
  local path="$1"
  local default="$2"

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "$default"
    return
  fi

  # Try Python with PyYAML for robust parsing
  if command -v python3 &>/dev/null; then
    python3 -c "
import sys
try:
    import yaml
    with open('$CONFIG_FILE') as f:
        config = yaml.safe_load(f) or {}

    # Navigate nested path
    value = config
    for key in '$path'.split('.'):
        if isinstance(value, dict) and key in value:
            value = value[key]
        else:
            print('$default')
            sys.exit(0)

    # Variable substitution
    if isinstance(value, str):
        import os
        result = value.replace('\${HOME}', os.path.expanduser('~'))
        if '\${user.' in result:
            user = config.get('user', {})
            result = result.replace('\${user.github_username}', user.get('github_username', ''))
            persona = user.get('persona', {}).get('description', '')
            result = result.replace('\${user.persona.description}', persona)
        print(result)
    else:
        print(value)
except ImportError:
    sys.exit(1)
except Exception:
    print('$default')
" 2>/dev/null && return
  fi

  # Fallback: simple grep
  local key="${path##*.}"
  grep "^[[:space:]]*${key}:" "$CONFIG_FILE" 2>/dev/null | \
    sed 's/.*:[[:space:]]*//' | tr -d '"' || echo "$default"
}

# Load with full nested paths
CONFIG=$(get_config "agents.your-agent.your_setting" "default")
```

### Step 3: Apply Config

Inject into agent logic:
```markdown
## Task Execution

Using **${CONFIG_SETTING}** preference from config...
```

### Step 4: Provide Defaults

Always include fallback values:
```bash
CONFIG=${CONFIG:-sensible_default}
```

## Examples

### Extract-Best-Frame

**Config:**
```yaml
agents:
  extract-best-frame:
    selection_criteria:
      optimize_for: "professional"
      target_person: "${user.persona.description}"
```

**Load:**
```bash
OPTIMIZE=$(get_config "agents.extract-best-frame.selection_criteria.optimize_for" "flattering")
TARGET=$(get_config "agents.extract-best-frame.selection_criteria.target_person" "the person")
```

### MakeResume

**Config:**
```yaml
agents:
  make-resume:
    paths:
      base_resume: "${HOME}/career/resume.md"
      output_dir: "${HOME}/career/resumes"
```

**Load:**
```bash
BASE=$(get_config "agents.make-resume.paths.base_resume" "${HOME}/resume.md")
OUT=$(get_config "agents.make-resume.paths.output_dir" "./resumes")
```

## Variable Substitution

Supports:
- `${HOME}` → Home directory
- `${user.github_username}` → User's GitHub username
- `${user.persona.description}` → User's persona

**Example:**
```yaml
path: "${HOME}/projects/${user.github_username}/output"
# Expands to: /home/user/projects/atxtechbro/output
```

## Validation

### Setup Script

```bash
if [ ! -f ~/.config/agents/agent-config.yml ]; then
  echo "Creating config from example..."
  cp .agent-config.example.yml ~/.config/agents/agent-config.yml
fi
```

### Runtime

```bash
if [ -z "$CONFIG_CRITICAL" ]; then
  echo "Error: Missing required config"
  exit 1
fi
```

## Security

**Secrets in environment variables, NOT config:**
```yaml
# ❌ Don't do this
github:
  api_token: "ghp_abc123..."

# ✅ Do this
github:
  api_token: "${GITHUB_TOKEN}"  # Read from env
```

**File permissions:**
```bash
chmod 600 ~/.config/agents/agent-config.yml
```

## Best Practices

**DO:**
- ✅ Provide sensible defaults for all config
- ✅ Use `${HOME}` for portability
- ✅ Document schema in `.example.yml`
- ✅ Validate critical config at runtime

**DON'T:**
- ❌ Hard-code personal data
- ❌ Store secrets in config file
- ❌ Fail silently if config missing
- ❌ Commit `.agent-config.yml` (gitignore it)

## Troubleshooting

**Config not loading?**
```bash
CONFIG_FILE="${DOTFILES_ROOT:-.}/.agent-config.yml"
echo "Looking for: $CONFIG_FILE"
[ -f "$CONFIG_FILE" ] && echo "✓ Found" || echo "✗ Not found"
```

**Variable not substituting?**
```bash
# Ensure using Python path, not grep fallback
python3 -c "import yaml; print('PyYAML available')" 2>/dev/null || echo "PyYAML missing"
```

## Migration

### Existing Agents

1. Identify hard-coded values (grep for literals)
2. Add to `.agent-config.example.yml`
3. Replace with `get_config()` calls
4. Test with different config values

### New Agents

1. Define config schema first
2. Use `get_config()` from the start
3. Always provide defaults

## See Also

- [Config in Environment Principle](../knowledge/principles/config-in-environment.md)
- [AI Harness Agnosticism](../knowledge/principles/ai-harness-agnosticism.md)
- [Extract-Best-Frame Example](../commands/extract-best-frame.md)
