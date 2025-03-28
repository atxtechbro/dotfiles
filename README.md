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

## CLI Tools

The following CLI tools can be installed using the scripts in the `tools/` directory:

- jira-cli - Jira command line interface

## Installing Tools

To install a tool, run its installation script:

```bash
# Make the script executable
chmod +x ~/dotfiles/tools/jira-cli.sh

# Run the installation script
~/dotfiles/tools/jira-cli.sh
```

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
