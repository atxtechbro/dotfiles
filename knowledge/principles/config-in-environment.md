# Config in Environment

**12-Factor Principle III**: An app's configuration should be stored in environment variables or config files, not hard-coded into the codebase.

## Core Concept

Configuration that varies between deployments (users, environments, contexts) should be externalized from code. This separation enables the same agent logic to serve different users with different preferences, workflows, and contexts without forking or modifying the source code.

In the context of AI agents: **users declare what they want** (the "what"), while **agents implement how to achieve it** (the "how"). The boundary between these is configuration.

## The Problem

Hard-coded configuration creates several issues:

1. **Blocks shareability** - Can't publish agents with personal data baked in
2. **Prevents personalization** - Users can't adapt agents to their preferences
3. **Requires code changes** - Every preference tweak needs editing procedure files
4. **Creates vendor lock-in** - Harness-specific assumptions prevent portability
5. **Inhibits community growth** - Users must fork instead of configure

### Real Examples from Our Agents

**Extract-Best-Frame:**
```markdown
# Hard-coded criteria (current)
For each pair, I'll select the more flattering selfie based on:
- Facial expression and smile
- Eye openness and engagement
```
**Problem:** What if user wants "professional" not "flattering"? What if multiple people in video?

**MakeResume:**
```bash
# Hard-coded paths (current)
career/sertifi-prs/processed/
career/resumes/${RESUME_DATE}-company-name.md
../resume.md
```
**Problem:** Assumes specific directory structure. Can't share publicly with personal paths.

**CloseIssue:**
```bash
# Assumed workflow (current)
# Branch naming: issue-{number}-{slug}
# Worktree location: Current repo's worktrees/
```
**Problem:** Users may have different naming conventions or worktree strategies.

## The Solution

### Declarative Configuration Layer

```
┌─────────────────────────────────────┐
│   Orchestration Layer               │  ← What to do (procedures)
│   (.claude/commands/*.md)            │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Configuration Layer               │  ← What the user wants
│   (.agent-config.yml)                │     - Preferences
│   or environment variables           │     - Paths
└─────────────────────────────────────┘     - Workflows
              ↓                              - Personas
┌─────────────────────────────────────┐
│   Implementation Layer              │  ← How to achieve it
│   (LLM reasoning + execution)        │
└─────────────────────────────────────┘
```

### Configuration Methods

**1. YAML Configuration Files** (Recommended for complex config)
```yaml
# .agent-config.yml
agents:
  extract-best-frame:
    optimize_for: "professional"  # vs "flattering", "candid"
    target_person:
      description: "6'3\", hazel eyes, athletic build"

  make-resume:
    paths:
      base_resume: "${HOME}/career/resume.md"
      output_dir: "${HOME}/career/resumes"
    github_username: "yourusername"

  close-issue:
    git:
      branch_naming: "issue-${issue_number}-${slug}"
      worktree_base: "${HOME}/ppv/pillars/worktrees"
```

**2. Environment Variables** (Recommended for simple overrides)
```bash
export EXTRACT_BEST_FRAME_CRITERIA="professional"
export MAKE_RESUME_OUTPUT_DIR="~/Documents/resumes"
export CLOSE_ISSUE_BRANCH_FORMAT="feature/${issue_number}"
```

**3. Hybrid Approach** (Best of both)
- Complex, structured config → YAML
- Simple overrides, secrets → Environment variables
- ENV vars override YAML (precedence: ENV > YAML > defaults)

## Implementation Pattern

### 1. Define Config Schema
```yaml
# .agent-config.yml (user-editable)
agents:
  extract-best-frame:
    selection_criteria:
      optimize_for: "flattering"  # Default value
      factors:
        - "facial_expression"
        - "eye_engagement"
        - "composition"
```

### 2. Agent Reads Config
```markdown
<!-- In extract-best-frame.md -->
## Step 0: Load Configuration

Read user preferences from .agent-config.yml using the get_config helper:

!# Load configuration with graceful defaults
!CONFIG_OPTIMIZE_FOR=$(get_config "agents.extract-best-frame.selection_criteria.optimize_for" "flattering")
!CONFIG_TARGET_PERSON=$(get_config "agents.extract-best-frame.selection_criteria.target_person" "the person in the video")
!
!echo "📋 Configuration loaded:"
!echo "  Selection criteria: $CONFIG_OPTIMIZE_FOR"
!echo "  Target person: $CONFIG_TARGET_PERSON"

The get_config function handles:
- Nested YAML navigation (agents.extract-best-frame.selection_criteria.optimize_for)
- Variable substitution (${HOME}, ${user.persona.description})
- Graceful fallback to defaults if config missing or PyYAML unavailable
```

**Note:** See `docs/config-architecture.md` for the full `get_config()` implementation.
This approach uses Python + PyYAML for robust parsing with graceful degradation.

### 3. Apply Config to Logic
```markdown
### Round 1: Selection Criteria

I'll compare frames based on **${CONFIG_OPTIMIZE_FOR}** criteria:
- ${CONFIG_FACTORS[0]}
- ${CONFIG_FACTORS[1]}
- ${CONFIG_FACTORS[2]}

Target person: ${CONFIG_TARGET_PERSON}
```

### 4. Graceful Degradation
Always provide sensible defaults if config is missing:
```bash
CONFIG_OPTIMIZE_FOR=${CONFIG_OPTIMIZE_FOR:-flattering}
CONFIG_OUTPUT_DIR=${CONFIG_OUTPUT_DIR:-./output}
CONFIG_BRANCH_FORMAT=${CONFIG_BRANCH_FORMAT:-issue-${issue_number}-${slug}}
```

## Benefits

### For Users
- **Personalization** - Agents adapt to preferences without code changes
- **Privacy** - Personal data lives in local config, not shared code
- **Flexibility** - Switch contexts (work/personal) by changing config
- **Transparency** - Config files document agent behavior clearly

### For Agent Publishers
- **Shareability** - Publish generic agents, users provide config
- **Community growth** - Lower barrier to adoption
- **Maintainability** - Config changes don't require code releases
- **Harness-agnosticism** - Config works across Claude Code, Cursor, Codex

### For The Ecosystem
- **Composability** - Mix and match agents with consistent config patterns
- **Discoverability** - `.agent-config.example.yml` shows capabilities
- **Contribution** - Community can improve agents without seeing personal data
- **Evolution** - Add new config options without breaking existing setups

## 12-Factor Methodology Alignment

This principle directly implements **12-Factor App Principle III**:

> **Config:** Store config in the environment
>
> "An app's *config* is everything that is likely to vary between deploys (staging, production, developer environments, etc). This includes:
> - Resource handles to databases, caches, and other backing services
> - Credentials to external services
> - Per-deploy values such as the canonical hostname for the deploy
>
> Apps sometimes store config as constants in the code. This is a violation of twelve-factor, which requires **strict separation of config from code**. Config varies substantially across deploys, code does not."

**Translation to AI Agents:**
- **"Deploys"** = Different users, contexts, or preferences
- **"Config"** = Selection criteria, paths, workflows, personas
- **"Code"** = Agent orchestration logic (procedures)

The same agent code should work for:
- Different users (Morgan vs. Jane vs. Bob)
- Different contexts (professional vs. personal)
- Different preferences (flattering vs. candid)
- Different harnesses (Claude Code vs. Cursor vs. Codex)

## Relationship to Other Principles

- **[AI Harness Agnosticism](ai-harness-agnosticism.md)**: Config enables portability across harnesses
- **[Systems Stewardship](systems-stewardship.md)**: Single source of truth for user preferences
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Removes need to fork agents
- **[Developer Experience](developer-experience.md)**: Editing YAML is easier than editing code

## Migration Strategy

### Phase 1: Tracer Bullet (Extract-Best-Frame)
1. Create minimal `.agent-config.yml` with one agent's config
2. Update agent to read and apply config
3. Test with multiple config values
4. Document pattern for other agents

### Phase 2: Apply Pattern (MakeResume, CloseIssue)
1. Identify hard-coded config in each agent
2. Extract to `.agent-config.yml`
3. Update procedures to read config
4. Test with different user configs

### Phase 3: Standardize & Publish
1. Create `.agent-config.example.yml` template
2. Document config schema and validation
3. Update setup.sh to handle config symlinks
4. Publish agents publicly with config documentation

## Config Storage Location

**Recommended:** `~/.config/agents/agent-config.yml`

**Rationale:**
- XDG Base Directory spec compliant (`~/.config/`)
- User-specific, not repo-specific
- Portable across different dotfiles versions
- Can be symlinked into harness directories

**Symlink Strategy:**
```bash
# In setup.sh
ln -sf ~/.config/agents/agent-config.yml "$DOTFILES_ROOT/.claude/.agent-config.yml"
ln -sf ~/.config/agents/agent-config.yml "$DOTFILES_ROOT/.codex/.agent-config.yml"
```

## Example: Extract-Best-Frame Config

**Before (hard-coded):**
```markdown
For each pair, I'll select the more flattering selfie based on:
- Facial expression and smile
- Eye openness and engagement
```

**After (configurable):**
```yaml
# .agent-config.yml
agents:
  extract-best-frame:
    optimize_for: "professional"
    factors:
      - "neutral_expression"
      - "direct_eye_contact"
      - "business_attire"
      - "clean_background"
    target_person:
      description: "Professional headshot subject"
```

**Result:** Same agent, different outcomes based on user intent.

## See Also

- [AI Harness Agnosticism](ai-harness-agnosticism.md) - Portability across tools
- [Systems Stewardship](systems-stewardship.md) - Configuration as truth
- [12-Factor App Methodology](https://12factor.net/config) - Original inspiration

## References

- [The Twelve-Factor App: III. Config](https://12factor.net/config)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

This principle transforms agents from "my personal tools" to "shareable, configurable systems" that respect user preferences while maintaining code simplicity.
