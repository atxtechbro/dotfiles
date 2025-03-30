# Dotfiles

## Manual Setup

To use these dotfiles, manually create symlinks from your home directory to this repository:

```bash
# Create Neovim config directory if it doesn't exist
mkdir -p ~/.config/nvim

# Create symlinks for configuration files
ln -sf ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -sf ~/dotfiles/.bash_exports ~/.bash_exports
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# Apply changes
source ~/.bashrc
```

That's it! Any changes you make to files in this repository will be reflected in your environment.

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

## CLI Tools

### jira-cli

[jira-cli](https://github.com/ankitpokhrel/jira-cli) is a feature-rich interactive Jira command line tool.

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
