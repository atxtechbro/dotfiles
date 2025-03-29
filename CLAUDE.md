# Claude Instructions for Dotfiles Repository

> **IMPORTANT**: This is a public repository. Do not add any proprietary information, secrets, API keys, or personal credentials to this repository.

## Commands
- **Install packages**: `./packages.sh`
- **Install tool**: `chmod +x tools/<tool-name>.sh && ./tools/<tool-name>.sh`
- **Neovim commands**:
  - `nvim` to start Neovim
  - `:PackerSync` to update/install Neovim plugins
  - `:checkhealth` to check Neovim health

## Code Style Guidelines
- **Lua**: 2-space indentation, no semicolons, `pcall` for error handling
- **Shell scripts**: Use `/bin/bash` shebang, double quotes for variables, error checks
- **Naming**: Use descriptive snake_case for functions, variables, and files
- **Patterns**: Follow existing patterns in similar files
- **Error handling**: Use defensive programming with checks and appropriate error messages
- **Documentation**: Document non-obvious code with brief comments
- **Git commits**: Use conventional commits format (feat, fix, docs, etc.)

## Folder Structure
- `bin/`: Utility scripts
- `tools/`: Installation scripts for third-party tools
- `nvim/`: Neovim configuration
- `keys/`: Public keys for package verification