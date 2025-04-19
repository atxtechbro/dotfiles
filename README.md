# Dotfiles

A collection of configuration files for a consistent development environment across different machines.

## P.P.V System: Pillars, Pipelines, and Vaults

This repository is part of the P.P.V system, a holistic approach to organizing knowledge work and digital assets:

### The P.P.V System

- **Pillars**: Core repositories, foundational configurations, and knowledge bases
- **Pipelines**: Automation scripts, workflows, and processes that connect tools and services
- **Vaults**: Secure storage for credentials, tokens, and tribal knowledge documentation

This organizational system provides a clear mental model for where different types of work should live:

```
~/
├── Pillars/                # Foundational repositories and configurations
│   ├── dotfiles/           # 📍 YOU ARE HERE - core configuration files
│   └── private-ppv/        # Private personal values and pillars (private git repo)
│       ├── pillars/        # Core pillars documentation
│       │   ├── core-pillars.md  # Define your own core pillars here
│       │   ├── principles/      # Your guiding principles
│       │   ├── strategic-objective.md # Your personal mission
│       │   └── faith-health-service/  # Example pillar with resources
│       │       └── fitness-data/      # Specific resources (e.g., gym equipment inventory, fitness goals)
│       ├── pipelines/      # Your personal automation workflows
│       └── vaults/         # Your private knowledge repositories
│
├── Pipelines/              # Automation and workflow repositories
│   └── ... (to be defined as needs arise)
│
└── Vaults/                 # Secure storage and tribal knowledge
    ├── credentials/        # API keys and access tokens (not in git)
    ├── certificates/       # SSL certificates and signing keys (not in git)
    ├── tribal-knowledge/   # Documentation for less-documented tools
    │   ├── internal-api.md # Notes on using internal APIs
    │   └── workflows.md    # Documented workflows for specific tasks
    └── configs/            # Environment-specific configurations
```

The P.P.V system helps maintain separation of concerns while providing a consistent structure across all projects and environments. It reflects systems thinking and the interconnectedness of different components in your workflow.

Key aspects:
- **Interconnected references**: Tools in `tools.md` can link to tribal knowledge in Vaults using URI schemes
- **Company separation**: Each company gets its own folder under Pillars for clear separation
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

### Neovim

For the latest version of Neovim, build from source:

```bash
# Install build prerequisites (Ubuntu/Debian)
sudo apt-get install ninja-build gettext cmake unzip curl

# Clone Neovim repository using GitHub CLI
gh repo clone neovim/neovim
cd neovim

# Build and install
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

This ensures you get the latest version with all features, rather than the potentially outdated version from package repositories.

For more build options, see the [official build instructions](https://github.com/neovim/neovim/blob/master/BUILD.md).

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

### Tmux Config Comparison

To compare different tmux configurations (like at an optometrist):

```bash
# Switch to main branch config
tmux-main

# Switch to PR branch config
tmux-pr
```

This is useful when testing different tmux configurations to see which one you prefer. You can quickly toggle between them like at the optometrist ("which is better, 1 or 2?").

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
