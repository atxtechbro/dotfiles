# Act Usage Guide

Act allows you to run GitHub Actions locally for faster development and testing.

## Installation

Act is installed automatically as a GitHub CLI extension when you run `setup.sh`. It's configured with lightweight Docker images and persistent caching for optimal performance.

## Basic Usage

### Run Default Workflow
```bash
# Run the default push event
gh act

# Run specific event
gh act pull_request
gh act workflow_dispatch
```

### List Available Workflows
```bash
# List all workflows and jobs
gh act -l

# List workflows for specific event
gh act -l pull_request
```

### Run Specific Workflow
```bash
# Run specific workflow file
gh act -W .github/workflows/ci.yml

# Run specific job within workflow
gh act -j test-job
```

## Advanced Usage

### Workflow Dispatch with Inputs
```bash
# Run workflow_dispatch with inputs
gh act workflow_dispatch --input key=value --input another=value

# Example from lifehacking project
gh act workflow_dispatch -W .github/workflows/process_prompt.yml \
  --input template=templates/test_template.md \
  --input output=test_output.md
```

### Debugging and Development

```bash
# Dry run (show what would be executed)
gh act --dryrun

# Verbose output for debugging
gh act -v

# Use specific platform
gh act -P ubuntu-latest=ubuntu:20.04

# Bind mount for faster file access
gh act --bind
```

### Environment Variables and Secrets

```bash
# Set environment variables
gh act -e GITHUB_TOKEN=your_token

# Use environment file
gh act --env-file .env

# Set secrets
gh act -s GITHUB_TOKEN=your_token
```

## Configuration

Act is configured via `~/.config/act/actrc` (managed by dotfiles):

```bash
# Platform mappings - lightweight images for faster startup
-P ubuntu-latest=node:16-buster-slim
-P ubuntu-22.04=node:16-buster-slim
-P ubuntu-20.04=node:16-buster-slim
-P ubuntu-18.04=node:16-buster-slim
-P self-hosted=node:16-buster-slim
-P macos-latest=node:16-buster-slim
-P windows-latest=node:16-buster-slim

# Caching configuration for faster runs
--action-cache-path ~/.cache/act
--use-new-action-cache
--action-offline-mode
```

## Docker Images

### Default Images (Lightweight)
- **node:16-buster-slim** (~200MB) - Fast startup, basic functionality
- Good for simple workflows with minimal dependencies

### Alternative Images (Full-featured)
If you need more complete environments, you can override:

```bash
# Use full GitHub Actions runner image (larger but more compatible)
gh act -P ubuntu-latest=catthehacker/ubuntu:act-latest

# Use specific image for one run
gh act -P ubuntu-latest=ubuntu:20.04
```

## Caching

Act caches actions and tools to speed up subsequent runs:

- **Actions cache**: `~/.cache/act/actions/` - Downloaded GitHub Actions
- **Tools cache**: `~/.cache/act/tools/` - Python, Node.js, etc.
- **Offline mode**: Uses cached actions when available

### Cache Management
```bash
# Clear cache if needed
rm -rf ~/.cache/act

# Check cache size
du -sh ~/.cache/act
```

## Common Workflows

### Testing Pull Request Workflows
```bash
# Test PR workflow locally before pushing
gh act pull_request

# Test with specific branch
gh act pull_request --eventpath pr-event.json
```

### CI/CD Development
```bash
# Test build workflow
gh act -j build

# Test with different inputs
gh act workflow_dispatch --input environment=staging
```

### Debugging Failed Actions
```bash
# Run with verbose output
gh act -v

# Use interactive mode (if supported)
gh act --interactive
```

## Troubleshooting

### Common Issues

**Docker not found:**
```bash
# Install Docker first
sudo apt install docker.io
sudo usermod -aG docker $USER
# Log out and back in
```

**Permission denied:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

**Action fails with missing tools:**
```bash
# Use fuller image
gh act -P ubuntu-latest=catthehacker/ubuntu:act-latest

# Or install tools in workflow
- name: Install dependencies
  run: apt-get update && apt-get install -y python3
```

**Slow performance:**
- Check if caching is enabled (should be by default)
- Use lighter Docker images for faster startup
- Ensure Docker has sufficient resources

### Getting Help
```bash
# Show act help
gh act --help

# Show version
gh act --version

# List available platforms
gh act -P
```

## Best Practices

1. **Use lightweight images** for faster iteration during development
2. **Enable caching** (configured by default) for faster subsequent runs
3. **Test locally** before pushing to avoid CI/CD failures
4. **Use specific events** rather than running all workflows
5. **Clean up containers** periodically: `docker system prune`

## Integration with Development Workflow

```bash
# Typical development cycle
git checkout -b feature/new-feature
# Make changes
gh act pull_request  # Test locally
git push origin feature/new-feature
# Create PR knowing it will pass
```

This local testing approach follows the "tracer bullets" principle - fast feedback loops to catch issues early.
