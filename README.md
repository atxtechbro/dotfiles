# Dotfiles

My personal dotfiles for setting up a consistent development environment across machines.

## Installation

Clone this repository and run the setup script:

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
./setup.sh
```

## Structure

- `bin/` - Custom scripts and binaries
- `install/` - Installation scripts for CLI tools
- `nvim/` - Neovim configuration
- `keys/` - SSH keys and other credentials
- `.bashrc`, `.bash_aliases`, etc. - Shell configuration files

## CLI Tools

The following CLI tools are automatically installed:

- jira-cli - Jira command line interface

## Adding New Tools

To add a new CLI tool:

1. Create an installation script in the `install/` directory (e.g., `install/new-tool.sh`)
2. Add the tool name to the `TOOLS` array in `install/install-tools.sh`
3. Run `./setup.sh` to install all tools or `./install/new-tool.sh` to install just the new tool

## License

MIT
