# MCP Server Examples

This directory contains example scripts and configurations for MCP servers.

## Project-Specific Servers

The `project-specific-servers.sh` script demonstrates how to enable or disable MCP servers based on project type detection. This is useful for automatically configuring the right set of MCP servers for different types of projects.

### Usage

```bash
# Configure MCP servers for the current directory
./project-specific-servers.sh

# Configure MCP servers for a specific project directory
./project-specific-servers.sh ~/projects/myapp
```

### How It Works

The script:

1. Detects project type by looking for specific files (package.json, requirements.txt, etc.)
2. Enables relevant MCP servers based on the detected project type
3. Disables irrelevant MCP servers to optimize performance

### Supported Project Types

- **Node.js**: Detected by presence of `package.json`
  - React: Detected by React dependency in `package.json`
  - Vue: Detected by Vue dependency in `package.json`

- **Python**: Detected by presence of `requirements.txt` or `pyproject.toml`
  - Django: Detected by Django dependency in `requirements.txt`
  - Flask: Detected by Flask dependency in `requirements.txt`

- **Java**: Detected by presence of `pom.xml` or `build.gradle`
  - Spring Boot: Detected by Spring Boot dependency in `pom.xml`

### Integration with Shell

You can integrate this script with your shell to automatically configure MCP servers when changing directories:

```bash
# Add to your .bashrc or .zshrc
cd_hook() {
  if [[ -f "package.json" || -f "requirements.txt" || -f "pom.xml" || -f "build.gradle" ]]; then
    ~/dotfiles/mcp/examples/project-specific-servers.sh "$(pwd)" > /dev/null
  fi
}

# Hook into cd command
cd() {
  builtin cd "$@" || return
  cd_hook
}
```

This will automatically configure MCP servers when you navigate to a project directory.

## Environment-Specific Servers

See the main documentation in `docs/mcp-environment.md` for information on how to configure environment-specific MCP servers.