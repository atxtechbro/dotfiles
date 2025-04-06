# Dotfiles

A collection of configuration files for a consistent development environment across different machines.

## Quick Setup

### Set Up Your Dotfiles

Get started with your personalized environment:

```bash
# Clone the repository and run setup
git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
cd ~/dotfiles
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
cp ~/dotfiles/.bash_secrets.example ~/.bash_secrets

# Set proper permissions to protect your secrets
chmod 600 ~/.bash_secrets

# Edit the file to add your specific secrets
nano ~/.bash_secrets
```

The `.bash_secrets` file is automatically loaded by `.bashrc`. It provides a framework for managing your secrets and environment variables, with examples of common patterns. You should customize it based on your needs.

For company-specific secrets, consider maintaining a separate private repository with additional templates and documentation.

## CLI Tools

### tmux

tmux is a terminal multiplexer that allows you to split your terminal into multiple panes and switch between them easily.

```bash
# Install tmux
sudo apt install -y tmux

# Create symlink for tmux configuration
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
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
```bash
curl --proto '=https' --tlsv1.2 -sSf https://desktop-release.q.us-east-1.amazonaws.com/latest/amazon-q.deb -o amazon-q.deb
sudo apt install -y ./amazon-q.deb
q
rm amazon-q.deb
```

*Note:* You'll need to provide your start URL during first-time setup (requires Pro license and SSO configuration).
The URL typically follows this format:
```bash
https://d-XXXXXXXXXX.awsapps.com/start/#/console?account_id=XXXXXXXXXXXX&role_name=YOUR_ROLE_NAME
```

Next step: run `q telemetry disable` - 'nuff said.

### Tmux Config Comparison

To compare different tmux configurations (like at an optometrist):

```bash
# Switch to main branch config
tmux-main

# Switch to PR branch config
tmux-pr
```

This is useful when testing different tmux configurations to see which one you prefer. You can quickly toggle between them like at the optometrist ("which is better, 1 or 2?").
