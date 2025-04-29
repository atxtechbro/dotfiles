# Neovim Scripts

This directory contains helper scripts used for Neovim setup and dependency management.

> **Note:** These scripts assume the `uv` Python package manager is already installed. The main `setup.sh` in the root directory installs `uv` if it's not present.

## Scripts

### 1. `lsp-install.sh`

Installs Language Server Protocol (LSP) servers and related dependencies for Neovim.

**Key features:**
- Uses `uv` with `--target ~/.local/uv-tools` for Python package management
- Installs core LSP servers via Mason
- Configures Python, Node.js, and Lua language support

### 2. `python-debug-install.sh`

Installs Python debugging tools for use with nvim-dap.

**Key features:**
- Uses `uv` with `--target ~/.local/uv-tools` for Python package management
- Installs debugpy for Python debugging
- Ensures nvim-dap plugins are installed

## Python Package Management

Both scripts use `uv` for Python package installation with the `--target` option:

```bash
uv pip install --target ~/.local/uv-tools package-name
```

This approach:
- Avoids modifying system Python
- Doesn't require creating virtual environments
- Keeps tools isolated in `~/.local/uv-tools`
- Works consistently across systems
- Is ideal for dotfiles that run on fresh machines

The scripts automatically add `~/.local/uv-tools/bin` to your PATH in `.bashrc` if needed.