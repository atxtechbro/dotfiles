# Claude Code PR Generator

This GitHub Action automatically generates pull requests from GitHub issues using Claude Code's CLI capabilities.

## Features

- Automatically processes issues labeled with 'ai-generate'
- Can be manually triggered for specific issues
- Uses Claude Code to analyze the repository and implement changes
- Creates a branch and pull request with the implementation
- Links the PR back to the original issue

## Usage

### Automatic Processing

1. Create an issue describing the feature or change you want
2. Add the 'ai-generate' label to the issue
3. The action will automatically create a PR with the implementation

### Manual Trigger

You can also trigger this action manually from the Actions tab:

1. Go to the Actions tab in your repository
2. Select the "Claude Code PR Generator" workflow
3. Click "Run workflow"
4. Enter the issue number you want to process
5. Click "Run workflow"

## Configuration

The action uses the following configuration:

- **System Prompt**: Uses AmazonQ.md as CLAUDE.md for guidance
- **MCP Configuration**: Sets up filesystem and GitHub access
- **Branch Naming**: Creates branches with pattern `ai-{issue-number}-{issue-title}`

## Extending

You can extend this action with additional AI-related labels:

- `ai-generate` - Generate a PR with code changes
- `ai-review` - Have Claude review an existing PR
- `ai-test` - Generate tests for the code in an issue/PR
- `ai-docs` - Generate documentation for the feature described

## Requirements

- GitHub Actions workflow permissions for contents, issues, and pull-requests
- Node.js environment for running Claude Code
