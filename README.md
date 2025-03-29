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
