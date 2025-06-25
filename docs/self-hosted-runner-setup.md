# Self-Hosted GitHub Actions Runner Setup

Guide for running the README memory update action on your own infrastructure.

## Why Self-Hosted?

- **Privacy**: Git history analysis stays on your infrastructure
- **Cost**: No GitHub Actions minutes consumed
- **Control**: Run on your schedule with your resources
- **Integration**: Can access local resources if needed

## Prerequisites

- Linux machine (physical or VM)
- Python 3.8+ installed
- Git installed
- GitHub Personal Access Token with repo permissions

## Setup Steps

### 1. Add Runner to Repository

1. Go to Settings → Actions → Runners in your fork
2. Click "New self-hosted runner"
3. Choose Linux and your architecture
4. Follow the provided commands to download and configure

### 2. Install as Service (Optional)

```bash
# Install as systemd service
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
```

### 3. Label Your Runner

Add labels to target specific runners:
- `linux` - OS type
- `python` - Has Python installed
- `dotfiles` - Dedicated to this repo

### 4. Security Considerations

- Run runner as non-root user
- Use dedicated user for GitHub Actions
- Limit runner to specific repositories
- Keep runner software updated

## Workflow Configuration

The workflow is configured to use self-hosted runners:

```yaml
runs-on: [self-hosted, linux]
```

Key differences from GitHub-hosted:
- Checks for Python availability before setup
- Cleans workspace after run
- Assumes git is already configured

## Testing

Test with manual dispatch:
```bash
gh workflow run update-readme-memory.yml --ref feature/self-hosted-runner-memory-update
```

## Monitoring

- Check runner status in GitHub UI
- Monitor system resources during runs
- Review action logs for issues

## Troubleshooting

### Runner Offline
```bash
# Check service status
sudo ./svc.sh status

# View logs
journalctl -u actions.runner.[repo-name].[runner-name] -f
```

### Permission Issues
- Ensure runner user has write access to workspace
- Check git credentials are configured

### Python Not Found
- Install Python 3: `sudo apt install python3`
- Or rely on workflow's fallback setup

## Benefits for This Use Case

1. **Continuous Context**: Runner maintains git history locally
2. **Faster Execution**: No checkout overhead for large repos
3. **Custom Schedule**: Run more frequently than GitHub's limits
4. **Local Integration**: Could extend to analyze local dev patterns

Principle: systems-stewardship