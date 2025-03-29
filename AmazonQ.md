# GitHub CLI Commands

> **IMPORTANT**: This is a public repository. Do not add any proprietary information, secrets, API keys, or personal credentials to this repository.

The GitHub CLI (`gh`) allows you to manage your GitHub repositories directly from the command line.

## Git Best Practices

### Moving Files While Preserving Git History

When moving files in a Git repository, use `git mv` instead of regular file system commands to preserve the file's history:

```bash
# Format: git mv <source> <destination>
git mv file.txt new/location/file.txt
```

This ensures that Git tracks the file movement as a rename operation rather than as a deletion and creation of a new file, preserving the commit history associated with the file.

## Repository Metadata Management

### Setting Repository Description (About Section)

To update the description (about section) of a repository:

```bash
# Format: gh repo edit [<repository>] --description "<description>"
gh repo edit --description "My personal dotfiles configuration"
```

If you're not in the repository directory, specify the repository name:

```bash
gh repo edit username/repo-name --description "My personal dotfiles configuration"
```

### Managing Repository Topics

To set topics for a repository (space-separated):

```bash
# Format: gh repo edit [<repository>] --add-topic topic1,topic2,topic3
gh repo edit --add-topic dotfiles,linux,configuration,bash,neovim
```

To remove topics:

```bash
# Format: gh repo edit [<repository>] --remove-topic topic1,topic2
gh repo edit --remove-topic old-topic
```

To replace all topics:

```bash
# Format: gh repo edit [<repository>] --topic topic1,topic2,topic3
gh repo edit --topic dotfiles,linux,configuration,bash,neovim
```

### Viewing Current Repository Metadata

To view the current repository information:

```bash
gh repo view --json name,description,topics
```

## Authentication

If you haven't authenticated with GitHub CLI yet:

```bash
gh auth login
```

Follow the prompts to authenticate with your GitHub account.

## Other Useful Repository Commands

```bash
# Create a new repository
gh repo create [name] [flags]

# Clone a repository
gh repo clone [repository]

# Fork a repository
gh repo fork [repository]

# View repository in browser
gh repo view --web
```

For more information, run `gh repo --help` or visit the [GitHub CLI documentation](https://cli.github.com/manual/).
