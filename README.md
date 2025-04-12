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
    path = ~/dotfiles/.gitconfig.signing
```

This modular approach lets you:
- Keep your main configuration clean
- Enable/disable features independently
- Share specific configurations across machines
- Test new configurations before fully adopting them

## Verified Git Commits

Setting up verified commits ensures that your contributions are authenticated and trusted on GitHub. When commits are verified, they display a "Verified" badge in the GitHub UI.

### SSH Key Signing (Recommended)

SSH key signing is simpler if you already use SSH keys for GitHub authentication:

```bash
# 1. Generate a dedicated signing key (no passphrase for convenience)
git gen-key

# 2. Include the signing configuration in your .gitconfig
[include]
    path = ~/dotfiles/.gitconfig.signing

# 3. Enable signing for all commits (optional)
git signing-on
```

Add your SSH key to GitHub:
1. Go to GitHub → Settings → SSH and GPG keys → New SSH key
2. Set "Key type" to "Signing Key"
3. Paste the output of: `git show-key`

### Convenient Git Aliases

The `.gitconfig.signing` file includes helpful aliases for managing signing:

```bash
# Available commands after including .gitconfig.signing:
git fix-agent      # Restart SSH agent and add key
git sc             # Make a signed commit
git verify-signing # Check if signing is working
git signing-on     # Enable signing for current repository
git signing-off    # Disable signing for current repository
git gen-key        # Generate a new signing key
git show-key       # Show your signing key fingerprint
git test-signing   # Test if signing is working
```

### Performance Optimization

The signing configuration intentionally uses:
- A faster elliptic curve algorithm (ECDSA-256) instead of slower alternatives
- A dedicated key without a passphrase to eliminate password prompts
- A short, convenient path for the key file

This approach prioritizes developer experience over maximum security, which is a reasonable trade-off for code signing. The security model assumes you control access to your development machine, but still provides the verification benefits on GitHub.

### Practical Considerations

Before enabling commit signing, consider these practical challenges:

- **Performance impact**: Signing adds a delay to each commit
- **Agent issues**: SSH agents may require occasional restarts (use `git fix-agent`)
- **Workflow disruption**: Password prompts can interrupt coding flow

### GPG Signing (Alternative)

For GPG signing:

```bash
# 1. Install GPG if not already installed
# Ubuntu/Debian:
sudo apt install -y gnupg

# 2. Generate a GPG key
gpg --full-generate-key
# Choose RSA and RSA, size 4096, no expiration

# 3. Get your key ID
gpg --list-secret-keys --keyid-format=long
# Look for sec rsa4096/YOUR_KEY_ID

# 4. Configure Git
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# 5. Export your public key
gpg --armor --export YOUR_KEY_ID
# Copy the output
```

Then add your GPG key to GitHub:
1. Go to GitHub → Settings → SSH and GPG keys → New GPG key
2. Paste your exported public key
