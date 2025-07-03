# Dotfiles

A collection of configuration files for a consistent development environment across different machines.

## Dotfiles Philosophy

Our dotfiles repository follows three core principles that guide our approach to configuration management:

### The Spilled Coffee Principle

The "spilled coffee principle" states that anyone should be able to destroy their machine and be fully operational again that afternoon. This principle emphasizes:

- All configuration changes should be reproducible across machines
- Setup scripts should handle file operations instead of manual commands
- Installation scripts should detect and create required directories
- Symlinks should be managed by setup scripts rather than manual linking
- Dependencies and installation steps should be well-documented

**❌ Common Violations - Manual Terminal Heroics:**

Like Brent from The Phoenix Project, we often become the constraint by being the "go-to hero" who fixes things manually. These commands are perfectly valid IN SCRIPTS, but become anti-patterns when typed directly in terminal:

```bash
# IN TERMINAL (BAD - Makes you Brent, the bottleneck hero):
dotfiles (main) $ ln -s mcp/mcp.json .mcp.json      # Works today, forgotten tomorrow
dotfiles (main) $ mv .bashrc .bashrc.backup          # Your knowledge, lost when you leave
dotfiles (main) $ chmod 600 ~/.bash_secrets          # New teammate: "Why doesn't this work?"
dotfiles (main) $ mkdir -p ~/ppv/pillars             # "It worked on my machine..."
dotfiles (main) $ echo "alias q='q'" >> ~/.bashrc   # Snowflake environment alert!
dotfiles (main) $ curl -o tool.tar.gz https://...    # Downloaded where? What version?

# The exact violation that inspired this documentation:
dotfiles (feature/vendor-agnostic-mcp-692) $ ln -s mcp/mcp.json .mcp.json
# ↑ I actually did this! Then immediately undid it and wrote a script instead.
```

**The Brent Test**: If you get hit by a bus (or take vacation), can someone else recreate what you did? If it's only in your terminal history, you're being Brent.

**✅ The Same Commands in Scripts (GOOD - No More Brent!):**
```bash
# IN SCRIPTS (GOOD - Knowledge is codified, not tribal):

# setup-vendor-agnostic-mcp.sh
ln -s mcp/mcp.json "$REPO_ROOT/.mcp.json"  # Reproducible by anyone

# setup.sh  
mkdir -p "$HOME/ppv/pillars"                # Self-documenting
chmod 600 ~/.bash_secrets                   # Security automated

# install-tool.sh
download_and_install_tool() {
    curl -o "$TEMP_DIR/tool.tar.gz" https://...  # Version controlled
}
```

**The Phoenix Principle**: Move from "Brent did it" to "The system does it". Every terminal command that changes state should become code, removing key person dependencies.

**The Litmus Test**: Can you destroy your laptop, get a new one, run `git clone && ./setup.sh`, and be back to exactly where you were? If not, you've been a hero instead of a steward.

This principle ensures resilience and quick recovery from system failures or when setting up new environments.

### The Snowball Method

The "snowball method" focuses on continuous knowledge accumulation and compounding improvements. Like a snowball rolling downhill, gathering more snow and momentum, this principle emphasizes:

- Persistent context: Each development session builds on accumulated knowledge from previous sessions
- Virtuous cycle: Tools and systems become more effective the more they're used
- Knowledge persistence: Documentation, configuration, and context are preserved and enhanced over time
- Compounding returns: Small improvements accumulate and multiply rather than remaining isolated
- Reduced cognitive load: Less need to "re-learn" or "re-discover" previous solutions

This principle ensures that our development environment continuously improves over time.

## Modular Shell Configuration

This repository uses a modular approach to shell configuration:

```bash
# Source modular alias files
for alias_file in ~/ppv/pillars/dotfiles/.bash_aliases.*; do
  [ -f "$alias_file" ] && source "$alias_file"
done
```

This pattern provides:
- **Separation of concerns** – Each file focuses on a specific tool
- **Lazy loading** – Files sourced only when they exist
- **Namespace hygiene** – Avoids cluttering global namespace

Modules follow the naming convention `.bash_aliases.<tool-name>` and are automatically loaded when present.

## P.P.V System: Pillars, Pipelines, and Vaults

This repository is part of the P.P.V system, a holistic approach to organizing knowledge work and digital assets:

### The P.P.V System

- **Pillars**: Core repositories, foundational configurations, and knowledge bases
- **Pipelines**: Automation scripts, workflows, and processes that connect tools and services
- **Vaults**: Secure storage for credentials, tokens, and tribal knowledge documentation

This organizational system provides a clear mental model for where different types of work should live:

```
/home/user/
└── ppv/                    # Root directory for P.P.V system
    ├── pillars/            # Foundational repositories and configurations
    │   └── dotfiles/       # 📍 YOU ARE HERE - core configuration files
    ├── pipelines/          # Automation and workflow repositories
    └── vaults/             # Secure storage and tribal knowledge
```

The P.P.V system helps maintain separation of concerns while providing a consistent structure across all projects and environments. It reflects systems thinking and the interconnectedness of different components in your workflow.

Key aspects:
- **Interconnected references**: Tools in `tools.md` can link to tribal knowledge in Vaults using URI schemes
- **Company separation**: Each company gets its own folder under pillars for clear separation
- **Principles first**: Core principles document guides all other decisions

## The 80/20 Rule for Systems Work

Following "Remember the Big Picture" from The Pragmatic Programmer - don't get so engrossed in system optimization details that you lose momentum on core work. In this dotfiles repo:

- **80% work**: Integrating systems, automation (Spilled Coffee Principle), core global rules
- **20% systems optimization**: Refining configurations, optimizing workflows, meta-work

Avoid obsessing over obscure details like perfect neovim configs or tmux panel layouts. The goal is systems that enable work, not systems as an end in themselves.

At an even higher level, this is all about **creating value by serving others**. Systems optimization plants seeds for higher leverage to serve better, but must be balanced with actually delivering that service. The "up high and slightly elevated" manager's perspective maintains this balance - constantly checking: "Am I committing real value? Are deliverables moving forward?"

This serving mindset acknowledges the tension as a pendulum rather than trying to eliminate it. Like Ecclesiastes 3:1 says, there's a season for everything - sometimes lean into systems work to build leverage, sometimes focus purely on delivery. The key is conscious awareness and feedback loops, always returning to: "How does this serve others better?"

## Repository Design Patterns

This repository follows specific organizational patterns to maintain consistency and clarity:

### Platform-Based Organization (Top Level)

At the root level, configurations are organized by platform or environment:

- `arch-linux/` - Configurations specific to Arch Linux systems
- `raspberry-pi/` - Configurations for Raspberry Pi devices
- `nvim/` - Neovim-specific configurations
- etc.

This structural organization makes it clear which files apply to which environments.

### Hybrid Organization (Within Platforms)

Within each platform directory, we use a hybrid approach combining categories and specific use cases:

```
raspberry-pi/
├── home/                  # Home use cases
│   ├── home-assistant/    # Smart home hub
│   └── media-server/      # Media streaming
├── development/           # Development use cases
│   └── ci-runner/         # Self-hosted CI/CD
└── networking/            # Networking use cases
    └── network-monitor/   # Traffic analysis
```

This approach:
- Organizes by general categories for maintainability
- Provides concrete examples for clarity
- Allows users to find configurations based on their intended use case

### Feature-Based Implementation

The actual implementation of features follows these principles:

1. **Detection over Assumption**: Scripts detect hardware capabilities rather than assuming specific use cases
2. **Composability**: Features can be mixed and matched based on user needs
3. **Automatic Optimization**: Hardware-specific optimizations are applied automatically
4. **Clear Documentation**: Each feature documents its purpose and requirements

This multi-level organizational approach allows us to maintain a clean repository structure while providing flexibility for different use cases.

## Quick Setup

### Set Up Your Dotfiles

Get started with your personalized environment:

```bash
# Clone the repository and run setup
git clone https://github.com/atxtechbro/dotfiles.git ~/ppv/pillars/dotfiles
cd ~/ppv/pillars/dotfiles
source setup.sh
```

The setup script automatically handles:
- Package installation and dependency management
- Creating all necessary symlinks
- Setting up your secrets file from the template
- Applying configurations immediately
- Installing and configuring essential tools (tmux, Amazon Q CLI, GitHub CLI, etc.)

Following the "Spilled Coffee Principle" - the setup script ensures you can be fully operational after running it once.

## AI Provider Agnostic Context

This repository automatically configures global context for multiple AI coding assistants from a single source of truth:

- **Amazon Q Developer CLI**: Uses symlinked rules directory (`~/.amazonq/rules/`)
- **Claude Code**: Uses generated `CLAUDE.local.md` files with embedded context

All context is sourced from the `knowledge/` directory and automatically configured by the setup script. See [AI Provider Agnostic Context](docs/ai-provider-agnostic-context.md) for details.

### Slash Commands (Vendor-Agnostic)

Slash commands are now stored in a vendor-agnostic structure that works across all AI coding assistants:

- **Templates**: Stored in `commands/templates/` (vendor-neutral location)
- **Generation**: Run `utils/generate-commands.sh` to process templates for all providers
- **Output**: Generated commands appear in provider-specific locations:
  - Claude Code: `~/.claude/commands/`
  - Amazon Q: (future support)
  - Other providers: (easily extensible)
- **Symlinks**: `.claude/command-templates` → `commands/templates/` (created by setup.sh)
- **Injection**: Templates use `{{ INJECT:path }}` to pull content from `knowledge/` directory
- **Variables**: Templates support variables like `{{ ISSUE_NUMBER }}` for dynamic content

To modify a slash command:
1. Edit the template in `commands/templates/`
2. Run `utils/generate-commands.sh` (automatically run by `source setup.sh`)
3. The updated command is available in all configured AI providers

**Principle**: This vendor-agnostic approach follows `systems-stewardship` - building reusable patterns across tools.

## Secret Management

Sensitive information like API tokens are stored in `~/.bash_secrets` (not tracked in git).

```bash
# Create your personal secrets file from the example template
cp ~/ppv/pillars/dotfiles/.bash_secrets.example ~/.bash_secrets

# Set proper permissions to protect your secrets
chmod 600 ~/.bash_secrets

# Edit the file to add your specific secrets
nano ~/.bash_secrets
```

The `.bash_secrets` file is automatically loaded by `.bashrc`. It provides a framework for managing your secrets and environment variables, with examples of common patterns. You should customize it based on your needs.

For company-specific secrets, consider maintaining a separate private repository in your Vaults directory.
