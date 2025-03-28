# Dotfiles

## Manual Setup

To use these dotfiles, manually create symlinks from your home directory to this repository:

```bash
# Create symlinks for configuration files
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -sf ~/dotfiles/.bash_exports ~/.bash_exports
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# Apply changes
source ~/.bashrc
```

That's it! Any changes you make to files in this repository will be reflected in your environment.
