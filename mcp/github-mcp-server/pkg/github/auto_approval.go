package github

import (
	"context"
	"fmt"
	"sync"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

// AutoApprovalChecker manages auto-approval logic for GitHub operations
type AutoApprovalChecker struct {
	enabled           bool
	authenticatedUser string
	getClient         GetClientFn
	mu                sync.RWMutex
	initialized       bool
}

// NewAutoApprovalChecker creates a new auto-approval checker
func NewAutoApprovalChecker(enabled bool, getClient GetClientFn) *AutoApprovalChecker {
	return &AutoApprovalChecker{
		enabled:   enabled,
		getClient: getClient,
	}
}

// Initialize fetches and caches the authenticated user
func (a *AutoApprovalChecker) Initialize(ctx context.Context) error {
	if !a.enabled {
		return nil
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	if a.initialized {
		return nil
	}

	client, err := a.getClient(ctx)
	if err != nil {
		return fmt.Errorf("failed to get GitHub client: %w", err)
	}

	user, _, err := client.Users.Get(ctx, "")
	if err != nil {
		return fmt.Errorf("failed to get authenticated user: %w", err)
	}

	if user.Login == nil {
		return fmt.Errorf("authenticated user has no login")
	}

	a.authenticatedUser = *user.Login
	a.initialized = true
	return nil
}

// CheckOperation checks if an operation should be auto-approved
func (a *AutoApprovalChecker) CheckOperation(ctx context.Context, owner, repo string, operationType string) error {
	if !a.enabled {
		// Auto-approval is disabled, allow all operations
		return nil
	}

	a.mu.RLock()
	if !a.initialized {
		a.mu.RUnlock()
		// Initialize if not already done
		if err := a.Initialize(ctx); err != nil {
			return fmt.Errorf("failed to initialize auto-approval: %w", err)
		}
		a.mu.RLock()
	}
	authenticatedUser := a.authenticatedUser
	a.mu.RUnlock()

	// Check if the owner matches the authenticated user
	if owner != authenticatedUser {
		return fmt.Errorf("operation on repository not owned by authenticated user (%s) requires manual approval", authenticatedUser)
	}

	// Get repository details to check if it's private
	client, err := a.getClient(ctx)
	if err != nil {
		return fmt.Errorf("failed to get GitHub client: %w", err)
	}

	repoDetails, _, err := client.Repositories.Get(ctx, owner, repo)
	if err != nil {
		return fmt.Errorf("failed to get repository details: %w", err)
	}

	// Check if repository is private
	if repoDetails.Private == nil || !*repoDetails.Private {
		return fmt.Errorf("operation on public repository requires manual approval for safety")
	}

	// Check for dangerous operations that always require approval
	dangerousOps := map[string]bool{
		"delete_repository":     true,
		"make_public":          true,
		"transfer_ownership":   true,
		"force_push_main":      true,
	}

	if dangerousOps[operationType] {
		return fmt.Errorf("operation '%s' always requires manual approval", operationType)
	}

	// All checks passed
	return nil
}

// IsEnabled returns whether auto-approval is enabled
func (a *AutoApprovalChecker) IsEnabled() bool {
	return a.enabled
}

// WrapHandler wraps a tool handler with auto-approval checks
func (a *AutoApprovalChecker) WrapHandler(operationType string, handler server.ToolHandlerFunc) server.ToolHandlerFunc {
	if !a.enabled {
		// Auto-approval is disabled, return the original handler
		return handler
	}

	return func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		// Extract owner and repo from the request if available
		owner, _ := RequiredParam[string](request, "owner")
		repo, _ := RequiredParam[string](request, "repo")

		// If we have owner and repo, check the operation
		if owner != "" && repo != "" {
			if err := a.CheckOperation(ctx, owner, repo, operationType); err != nil {
				return mcp.NewToolResultError(fmt.Sprintf("Auto-approval check failed: %v", err)), nil
			}
		}

		// All checks passed, execute the original handler
		return handler(ctx, request)
	}
}