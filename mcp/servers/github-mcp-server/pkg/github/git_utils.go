package github

import (
	"fmt"
	"os/exec"
	"strings"
)

// getCurrentBranch gets the current branch name for a repository
func getCurrentBranch(owner, repo string) (string, error) {
	// Construct the repository path
	repoPath := fmt.Sprintf("%s/%s", owner, repo)
	
	// Execute git branch --show-current
	cmd := exec.Command("git", "-C", repoPath, "branch", "--show-current")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("failed to get current branch: %w", err)
	}
	
	return strings.TrimSpace(string(output)), nil
}

// executeGitCommand executes a git command in the repository
func executeGitCommand(owner, repo string, args ...string) error {
	// Construct the repository path
	repoPath := fmt.Sprintf("%s/%s", owner, repo)
	
	// Prepare the command with the repository path
	cmdArgs := append([]string{"-C", repoPath}, args...)
	cmd := exec.Command("git", cmdArgs...)
	
	// Execute the command
	_, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("failed to execute git command: %w", err)
	}
	
	return nil
}
