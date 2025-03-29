# AI Assistant Guide - Claude

> **IMPORTANT**: This is a public repository. Do not add any proprietary information, secrets, API keys, or personal credentials to this repository.

This file contains guidance for Claude when interacting with this repository. It represents my preferences, opinions, and domain-specific knowledge that I want Claude to consider when providing assistance.

## Repository Purpose & Philosophy

This dotfiles repository serves as my personal development environment configuration. Its purpose is to:
- Maintain consistent development environments across different machines
- Allow quick setup of a new development environment
- Store configurations as code for version control and portability
- Serve as a reference for useful commands and tools

When helping with this repository, prioritize:
- Maintainability over complexity
- Clear documentation over clever code
- Consistency with existing patterns
- Security best practices

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