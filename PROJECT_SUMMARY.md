# Dotfiles Project Summary

## Overview

This repository contains a comprehensive collection of configuration files and setup scripts designed to create a consistent, reproducible development environment across different machines. It follows a philosophy centered around three core principles: the Spilled Coffee Principle (quick recovery), the Snowball Method (knowledge accumulation), and the Versioning Mindset (iterative improvement).

The project is organized as part of a larger P.P.V (Pillars, Pipelines, and Vaults) system for managing digital assets and knowledge work. This dotfiles repository serves as a foundational "Pillar" in that system.

## Key File Paths and Their Purpose

### Core Configuration Files
- `/.bashrc` - Main Bash configuration file
- `/.bash_aliases` - Core aliases for Bash
- `/.bash_aliases.*` - Modular alias files for specific tools
- `/.bash_aliases.d/` - Directory for modular alias files
- `/.bash_exports` - Environment variable exports
- `/.bash_profile` - Login shell configuration
- `/.bash_secrets.example` - Template for managing sensitive information
- `/.tmux.conf` - Configuration for tmux terminal multiplexer

### Setup and Installation
- `/setup.sh` - Main setup script that creates symlinks and configures the environment
- `/utils/` - Directory containing utility scripts for various tasks
- `/utils/install-go.sh` - Script for installing Go programming language

### Platform-Specific Configurations
- `/arch-linux/` - Configurations specific to Arch Linux
- `/raspberry-pi/` - Configurations for Raspberry Pi devices
- `/nvim/` - Neovim editor configuration

### MCP (Model Context Protocol) Integration
- `/mcp/` - Directory for MCP-related scripts and configurations
- `/mcp/servers/` - MCP servers for different tools and services
- `/mcp/*-mcp-wrapper.sh` - Wrapper scripts for various MCP servers

## Dependencies and Tools

### Core Dependencies
- `git` - Version control system
- `curl` - Command-line tool for transferring data
- `bash` - Shell environment

### Recommended Tools
- `tmux` - Terminal multiplexer
- `jq` - Command-line JSON processor
- `gh` - GitHub CLI
- `wget` - Network downloader

### AI and Development Tools
- `Amazon Q CLI` - AI assistant for development
- `Claude Code` - AI coding assistant
- `Clojure MCP` - REPL-based development with AI assistance

## Architecture and Component Interaction

The dotfiles repository follows a modular architecture with several key design patterns:

1. **Modular Shell Configuration**: Configuration is split into purpose-specific files that are automatically loaded.
   ```bash
   # Source modular alias files
   for alias_file in ~/ppv/pillars/dotfiles/.bash_aliases.*; do
     [ -f "$alias_file" ] && source "$alias_file"
   done
   ```

2. **Platform-Based Organization**: Top-level directories are organized by platform or environment.

3. **Hybrid Organization**: Within platform directories, configurations are organized by categories and specific use cases.

4. **Feature-Based Implementation**: Features follow principles like "Detection over Assumption" and "Composability".

5. **Secret Management**: Sensitive information is stored in `~/.bash_secrets` (not tracked in git).

## Implementation Patterns and Conventions

### Git Workflow
- Conventional commit syntax: `<type>[scope]: description`
- Branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Pull Request based workflow
- Tracer bullet / vibe coding development style

### File Organization
- Configuration files are organized by platform and purpose
- Setup scripts handle file operations instead of manual commands
- Symlinks are managed by setup scripts rather than manual linking

### MCP Integration
- MCP servers extend AI assistant capabilities
- Wrapper scripts provide consistent interfaces to different MCP servers
- REPL-based development workflows with AI assistance

## Development Workflow

1. **Setup**: Clone the repository and run the setup script
   ```bash
   git clone https://github.com/atxtechbro/dotfiles.git ~/ppv/pillars/dotfiles
   cd ~/ppv/pillars/dotfiles
   ./setup.sh
   ```

2. **Customization**: Modify configuration files as needed
   - Add new aliases to `.bash_aliases.*` files
   - Add environment variables to `.bash_exports`
   - Store sensitive information in `~/.bash_secrets`

3. **Contribution**: Follow the Git workflow for contributions
   - Create feature branches for new features
   - Use conventional commit messages
   - Submit pull requests for review

## Extension Points

### Adding New Tools
1. Create a new `.bash_aliases.<tool-name>` file for tool-specific aliases
2. Add installation instructions to the README.md
3. Create setup scripts in the `utils/` directory if needed

### Platform-Specific Extensions
1. Create a new directory for the platform (e.g., `macos/`)
2. Add platform-specific configuration files
3. Update the setup script to detect and handle the new platform

### MCP Server Integration
1. Add new MCP server in the `mcp/servers/` directory
2. Create a wrapper script in the `mcp/` directory
3. Document the server's capabilities and usage

### Modular Git Configuration
1. Create a new `.gitconfig.<feature>` file
2. Document how to include it in the user's `.gitconfig`

## Recent Developments

1. **MCP Output Formatting**: Issue #345 has been created to improve the readability of MCP tool output by modifying the Amazon Q CLI source code.

2. **Git MCP Server**: Updated to use the atxtechbro repository instead of external repositories.

3. **Gitignore Improvements**: Updated to properly ignore the mcp/servers directory and .cpcache directory.

4. **Detection over Assumption Principle**: This principle has been applied to the MCP output formatting issue, focusing on detecting patterns in output and transforming them into a more readable format.