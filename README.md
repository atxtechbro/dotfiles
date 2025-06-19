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

**❌ Counterexample - What NOT to do:**
```bash
# Don't give one-off commands like this:
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.unix-executable";LSHandlerRoleAll="com.googlecode.iterm2";}'
```

**✅ Instead - Add to setup script:**
```bash
# Add to setup.sh so it's reproducible
configure_iterm_as_default_terminal() {
    defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.unix-executable";LSHandlerRoleAll="com.googlecode.iterm2";}'
}
```

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

## Tool Choices and Trade-offs

### Amazon Q CLI as Primary MCP Client

I use Amazon Q CLI ($20/month) as my **MCP client** - not just an AI interface, but the hub of my development workflow. This choice reflects my AI-first development philosophy:

**Why Amazon Q CLI as MCP Client:**
- **True agentic capability**: Executes ambiguous searches, resolves GitHub issues - not some cheap plugin
- **MCP ecosystem hub**: Native client for my entire MCP server infrastructure (git, filesystem, brave search, etc.)
- **Economic efficiency**: Nearly unlimited queries vs. expensive per-token models
- **Work/personal separation**: Separate accounts for clean context boundaries and quota management
- **CLI-first integration**: Perfect fit for tmux/nvim terminal-based workflow
- **200k context window**: Enables deep, persistent conversations following the Snowball Method

**AI-First Development Philosophy:**
As an AI-first developer, I see little need for traditional IDEs. Modern IDEs with "AI bolted on" are ill-equipped for chat-based coding and tracer bullets development. My command line is more truly "integrated" than any so-called Integrated Development Environment. I don't optimize for writing out code - I optimize for AI collaboration and rapid iteration.

**Trade-offs accepted:**
- Frequent reauthentication (annoying bright white browser screen)
- Less scriptable than Claude Code
- More complex initial setup than alternatives
- Less gamified/polished interface

**Philosophy alignment:**
The tool's serious, less-gamified nature reinforces the 80/20 rule - focusing on substance over polish. While authentication friction seems to violate "Keep joy in the loop," it actually serves the broader principle by maintaining focus on delivery rather than aesthetic minutiae.

This README documents authentic personal choices and trade-offs for my future self, not AI-generated marketing copy.

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
