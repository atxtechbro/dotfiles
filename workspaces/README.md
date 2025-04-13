# Dotfiles Workspaces

A workspace system for managing multiple repositories and development environments.

## What are Workspaces?

Workspaces allow you to:
- Group related repositories together
- Set up consistent development environments
- Launch all necessary tools with a single command
- Switch between different projects easily

## Usage

```bash
# Create a new workspace
workspace create my-project

# Load an existing workspace
workspace load my-project

# List available workspaces
workspace list

# Edit a workspace configuration
workspace edit my-project
```

## Workspace File Format

Workspace files are JSON files stored in `~/dotfiles/workspaces/` with the following structure:

```json
{
  "name": "Project Name",
  "description": "Project description",
  "repos": [
    {
      "path": "~/projects/repo1",
      "name": "Repository 1",
      "branch": "main"
    },
    {
      "path": "~/projects/repo2",
      "name": "Repository 2",
      "branch": "develop"
    }
  ],
  "tmux": {
    "layout": "main-vertical",
    "commands": [
      "cd ~/projects/repo1 && npm start",
      "cd ~/projects/repo2 && ./run-dev.sh"
    ]
  },
  "environment": {
    "NODE_ENV": "development",
    "API_URL": "http://localhost:3000"
  },
  "tools": [
    "node",
    "python",
    "docker"
  ]
}
```

## Integration

Workspaces integrate with:
- tmux for terminal multiplexing
- bash/zsh for environment variables
- git for repository management
- VSCode for editor configuration
