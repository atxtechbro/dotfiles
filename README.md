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

This principle ensures resilience and quick recovery from system failures or when setting up new environments.

### The Snowball Method

The "snowball method" focuses on continuous knowledge accumulation and compounding improvements. Like a snowball rolling downhill, gathering more snow and momentum, this principle emphasizes:

- Persistent context: Each development session builds on accumulated knowledge from previous sessions
- Virtuous cycle: Tools and systems become more effective the more they're used
- Knowledge persistence: Documentation, configuration, and context are preserved and enhanced over time
- Compounding returns: Small improvements accumulate and multiply rather than remaining isolated
- Reduced cognitive load: Less need to "re-learn" or "re-discover" previous solutions

This principle ensures that our development environment continuously improves over time.

### The Versioning Mindset

The "versioning mindset" is the principle that progress happens through iteration rather than reinvention, where small strategic changes compound over time through active feedback loops. It emphasizes:

- Logging what worked and what didn't, then rolling forward with improvements
- Creating feedback loops across domains so gains in one area reinforce others
- Focusing on incremental improvements rather than complete rewrites
- Building on previous knowledge rather than starting from scratch
- Maintaining history and context to inform future decisions

This principle ensures sustainable, continuous improvement across all aspects of our development environment.

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
./setup.sh
```

The setup script will:
- Create all necessary symlinks
- Set up your secrets file from the template
- Apply configurations immediately

The script will NOT install packages for you or make assumptions about your package manager.

> **Note:** The setup script requires `git` and `curl`. Most systems have these installed by default, but if you encounter errors, see the package installation section below.

### Recommended Packages

These packages enhance your development experience but are not required for the dotfiles setup:

<details>
<summary><b>Ubuntu/Debian</b></summary>

```bash
sudo apt update
sudo apt install -y git gh jq tmux curl wget
```
</details>

<details>
<summary><b>Arch Linux</b></summary>

```bash
sudo pacman -Syu
sudo pacman -S --needed git github-cli jq tmux curl wget
```
</details>

<details>
<summary><b>macOS</b></summary>

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential packages
brew install git gh jq tmux curl wget
```
</details>

## Applications

### Google Chrome

Install Google Chrome with automatic updates via the official Google repository:

```bash
# Add Google Chrome repository key
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Add the Google Chrome repository
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'

# Update package lists and install Chrome
sudo apt update
sudo apt install -y google-chrome-stable
```

Chrome will automatically update when you run `sudo apt update` and `sudo apt upgrade` as part of your regular system maintenance.

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

## CLI Tools

### Go

Go is a statically typed, compiled programming language designed at Google. It's used by many modern tools including the GitHub MCP server.

```bash
# Install Go automatically using our utility script
./utils/install-go.sh

# Verify installation
go version
```

The installation script:
- Detects your operating system and architecture
- Attempts to install Go using your system's package manager
- Falls back to manual installation from official binaries if needed
- Sets up proper environment variables
- Creates necessary workspace directories

This script follows the "spilled coffee principle" - it ensures Go is available without manual intervention, making your environment fully operational after a fresh setup.

### tmux

tmux is a terminal multiplexer that allows you to split your terminal into multiple panes and switch between them easily.

```bash
# Install tmux
sudo apt install -y tmux

# Create symlink for tmux configuration
ln -sf ~/ppv/pillars/dotfiles/.tmux.conf ~/.tmux.conf
```

Basic usage:
- Start a new session: `tmux`
- Split pane horizontally: `Ctrl+a -`
- Split pane vertically: `Ctrl+a |`
- Navigate between panes: `Alt+Arrow Keys`
- Close current pane: `Ctrl+a x`
- Detach from session: `Ctrl+a d`
- Reattach to session: `tmux attach`

### jira-cli

[jira-cli](https://github.com/ankitpokhrel/jira-cli) is a feature-rich interactive Jira command line tool.

For Atlassian Cloud authentication:
```bash
# Generate an API token at: https://id.atlassian.com/manage-profile/security/api-tokens
# Add it to your ~/.bash_secrets file
# Initialize jira-cli
jira init
```

For installation instructions, see the [official installation guide](https://github.com/ankitpokhrel/jira-cli/wiki/Installation).

## CLI AI tools

### Claude Code
```bash
npm install -g @anthropic-ai/claude-code
claude
```

### Amazon Q CLI
*Note:* Amazon Q installation and updates are automatically handled by the setup script.

During first-time setup, you'll need to authenticate with either:
- AWS Builder ID (personal use)
- SSO configuration (for Pro license with organization access)

For SSO, the URL typically follows this format:
```bash
https://d-XXXXXXXXXX.awsapps.com/start/#/console?account_id=XXXXXXXXXXXX&role_name=YOUR_ROLE_NAME
```

### REPL-Based Development with MCP

This repository includes support for REPL-based development workflows using the Model Context Protocol (MCP), which exemplifies our "Snowball Method" principle. This integration creates a virtuous cycle where each development session builds on the accumulated knowledge of previous sessions.

#### Clojure MCP Integration

The Clojure MCP integration allows you to leverage REPL-driven development with any MCP-compatible AI assistant:

```bash
# Install and set up Clojure MCP
cd ~/ppv/pillars/dotfiles/mcp
./setup-clojure-mcp.sh

# Start the Clojure MCP server
clj-mcp-start

# In a new terminal, start a REPL session
clj-mcp
```

Key features:
- **Client-Agnostic**: Works with Amazon Q, Claude, GitHub Copilot, or any MCP-compatible client
- **Persistent Context**: Maintains session history between development sessions
- **Knowledge Accumulation**: Each session builds on previous ones, creating a snowball effect
- **Project Summaries**: Generate documentation based on your development history

For example, to create a new Clojure project with MCP integration:
```bash
clj-mcp-new-project my-project
cd my-project
clj-mcp
```

To save and load REPL sessions (preserving context):
```bash
# Save the current session
clj-mcp-save-session my-session.edn

# Load a previous session
clj-mcp-load-session my-session.edn
```

To generate a project summary based on your REPL history:
```bash
clj-mcp-summarize
```

This implementation demonstrates the "Snowball Method" in action:
1. **Persistent Context**: The REPL maintains state between evaluations
2. **Virtuous Cycle**: The more you use it, the more effective it becomes
3. **Knowledge Persistence**: Session history is preserved and enhanced over time
4. **Compounding Returns**: Small improvements accumulate and multiply
5. **Reduced Cognitive Load**: Less need to "re-learn" previous solutions

## WSL Tips
- **Distraction-Free Mode**: Press `Alt+Enter` in Windows Terminal to toggle full-screen and hide the taskbar.

## Modular Git Configuration

This dotfiles repository uses a modular approach to Git configuration, allowing you to enable specific features as needed without cluttering your main configuration.

### Available Git Configuration Modules

- `.gitconfig.signing` - Commit signing configuration with SSH keys
- (Add more modules as they are created)

To include a module in your Git configuration:

```bash
# Add this to your ~/.gitconfig
[include]
    path = ~/ppv/pillars/dotfiles/.gitconfig.signing
```
