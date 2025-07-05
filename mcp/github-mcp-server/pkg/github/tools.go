package github

import (
	"context"

	"github.com/github/github-mcp-server/pkg/raw"
	"github.com/github/github-mcp-server/pkg/toolsets"
	"github.com/github/github-mcp-server/pkg/translations"
	"github.com/google/go-github/v72/github"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
	"github.com/shurcooL/githubv4"
)

type GetClientFn func(context.Context) (*github.Client, error)
type GetGQLClientFn func(context.Context) (*githubv4.Client, error)

var DefaultTools = []string{"all"}

// wrapWriteTool wraps a write tool with auto-approval checks if enabled
func wrapWriteTool(tool func() (mcp.Tool, server.ToolHandlerFunc), operationType string, checker *AutoApprovalChecker) server.ServerTool {
	t, h := tool()
	if checker != nil && checker.IsEnabled() {
		h = checker.WrapHandler(operationType, h)
	}
	return toolsets.NewServerTool(t, h)
}

func DefaultToolsetGroup(readOnly bool, writeOnly bool, getClient GetClientFn, getGQLClient GetGQLClientFn, getRawClient raw.GetRawClientFn, t translations.TranslationHelperFunc, autoApprovalChecker *AutoApprovalChecker) *toolsets.ToolsetGroup {
	tsg := toolsets.NewToolsetGroup(readOnly, writeOnly)

	// Define all available features with their default state (disabled)
	// Create toolsets
	repos := toolsets.NewToolset("repos", "GitHub Repository related tools").
		AddReadTools(
			toolsets.NewServerTool(SearchRepositories(getClient, t)),
			toolsets.NewServerTool(GetFileContents(getClient, getRawClient, t)),
			toolsets.NewServerTool(ListCommits(getClient, t)),
			toolsets.NewServerTool(SearchCode(getClient, t)),
			toolsets.NewServerTool(GetCommit(getClient, t)),
			toolsets.NewServerTool(ListBranches(getClient, t)),
			toolsets.NewServerTool(ListTags(getClient, t)),
			toolsets.NewServerTool(GetTag(getClient, t)),
		).
		AddWriteTools(
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return CreateOrUpdateFile(getClient, t) }, "create_or_update_file", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return CreateRepository(getClient, t) }, "create_repository", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return ForkRepository(getClient, t) }, "fork_repository", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return CreateBranch(getClient, t) }, "create_branch", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return PushFiles(getClient, t) }, "push_files", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return DeleteFile(getClient, t) }, "delete_file", autoApprovalChecker),
		).
		AddResourceTemplates(
			toolsets.NewServerResourceTemplate(GetRepositoryResourceContent(getClient, getRawClient, t)),
			toolsets.NewServerResourceTemplate(GetRepositoryResourceBranchContent(getClient, getRawClient, t)),
			toolsets.NewServerResourceTemplate(GetRepositoryResourceCommitContent(getClient, getRawClient, t)),
			toolsets.NewServerResourceTemplate(GetRepositoryResourceTagContent(getClient, getRawClient, t)),
			toolsets.NewServerResourceTemplate(GetRepositoryResourcePrContent(getClient, getRawClient, t)),
		)
	issues := toolsets.NewToolset("issues", "GitHub Issues related tools").
		AddReadTools(
			toolsets.NewServerTool(GetIssue(getClient, t)),
			toolsets.NewServerTool(SearchIssues(getClient, t)),
			toolsets.NewServerTool(ListIssues(getClient, t)),
			toolsets.NewServerTool(GetIssueComments(getClient, t)),
		).
		AddWriteTools(
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return CreateIssue(getClient, t) }, "create_issue", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return AddIssueComment(getClient, t) }, "add_issue_comment", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return UpdateIssue(getClient, t) }, "update_issue", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return AssignCopilotToIssue(getGQLClient, t) }, "assign_copilot_to_issue", autoApprovalChecker),
		).AddPrompts(toolsets.NewServerPrompt(AssignCodingAgentPrompt(t)))
	users := toolsets.NewToolset("users", "GitHub User related tools").
		AddReadTools(
			toolsets.NewServerTool(SearchUsers(getClient, t)),
		)
	orgs := toolsets.NewToolset("orgs", "GitHub Organization related tools").
		AddReadTools(
			toolsets.NewServerTool(SearchOrgs(getClient, t)),
		)
	pullRequests := toolsets.NewToolset("pull_requests", "GitHub Pull Request related tools").
		AddReadTools(
			toolsets.NewServerTool(GetPullRequest(getClient, t)),
			toolsets.NewServerTool(ListPullRequests(getClient, t)),
			toolsets.NewServerTool(GetPullRequestFiles(getClient, t)),
			toolsets.NewServerTool(SearchPullRequests(getClient, t)),
			toolsets.NewServerTool(GetPullRequestStatus(getClient, t)),
			toolsets.NewServerTool(GetPullRequestComments(getClient, t)),
			toolsets.NewServerTool(GetPullRequestReviews(getClient, t)),
			toolsets.NewServerTool(GetPullRequestDiff(getClient, t)),
		).
		AddWriteTools(
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return MergePullRequest(getClient, t) }, "merge_pull_request", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return UpdatePullRequestBranch(getClient, t) }, "update_pull_request_branch", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return CreatePullRequest(getClient, t) }, "create_pull_request", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return UpdatePullRequest(getClient, t) }, "update_pull_request", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return RequestCopilotReview(getClient, t) }, "request_copilot_review", autoApprovalChecker),

			// Reviews
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return CreateAndSubmitPullRequestReview(getGQLClient, t) }, "create_and_submit_pull_request_review", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return CreatePendingPullRequestReview(getGQLClient, t) }, "create_pending_pull_request_review", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return AddPullRequestReviewCommentToPendingReview(getGQLClient, t) }, "add_pull_request_review_comment", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return SubmitPendingPullRequestReview(getGQLClient, t) }, "submit_pending_pull_request_review", autoApprovalChecker),
			wrapWriteTool(func() (mcp.Tool, server.ToolHandlerFunc) { return DeletePendingPullRequestReview(getGQLClient, t) }, "delete_pending_pull_request_review", autoApprovalChecker),
		)
	codeSecurity := toolsets.NewToolset("code_security", "Code security related tools, such as GitHub Code Scanning").
		AddReadTools(
			toolsets.NewServerTool(GetCodeScanningAlert(getClient, t)),
			toolsets.NewServerTool(ListCodeScanningAlerts(getClient, t)),
		)
	secretProtection := toolsets.NewToolset("secret_protection", "Secret protection related tools, such as GitHub Secret Scanning").
		AddReadTools(
			toolsets.NewServerTool(GetSecretScanningAlert(getClient, t)),
			toolsets.NewServerTool(ListSecretScanningAlerts(getClient, t)),
		)

	notifications := toolsets.NewToolset("notifications", "GitHub Notifications related tools").
		AddReadTools(
			toolsets.NewServerTool(ListNotifications(getClient, t)),
			toolsets.NewServerTool(GetNotificationDetails(getClient, t)),
		).
		AddWriteTools(
			toolsets.NewServerTool(DismissNotification(getClient, t)),
			toolsets.NewServerTool(MarkAllNotificationsRead(getClient, t)),
			toolsets.NewServerTool(ManageNotificationSubscription(getClient, t)),
			toolsets.NewServerTool(ManageRepositoryNotificationSubscription(getClient, t)),
		)

	actions := toolsets.NewToolset("actions", "GitHub Actions workflows and CI/CD operations").
		AddReadTools(
			toolsets.NewServerTool(ListWorkflows(getClient, t)),
			toolsets.NewServerTool(ListWorkflowRuns(getClient, t)),
			toolsets.NewServerTool(GetWorkflowRun(getClient, t)),
			toolsets.NewServerTool(GetWorkflowRunLogs(getClient, t)),
			toolsets.NewServerTool(ListWorkflowJobs(getClient, t)),
			toolsets.NewServerTool(GetJobLogs(getClient, t)),
			toolsets.NewServerTool(ListWorkflowRunArtifacts(getClient, t)),
			toolsets.NewServerTool(DownloadWorkflowRunArtifact(getClient, t)),
			toolsets.NewServerTool(GetWorkflowRunUsage(getClient, t)),
		).
		AddWriteTools(
			toolsets.NewServerTool(RunWorkflow(getClient, t)),
			toolsets.NewServerTool(RerunWorkflowRun(getClient, t)),
			toolsets.NewServerTool(RerunFailedJobs(getClient, t)),
			toolsets.NewServerTool(CancelWorkflowRun(getClient, t)),
			toolsets.NewServerTool(DeleteWorkflowRunLogs(getClient, t)),
		)

	// Keep experiments alive so the system doesn't error out when it's always enabled
	experiments := toolsets.NewToolset("experiments", "Experimental features that are not considered stable yet")

	contextTools := toolsets.NewToolset("context", "Tools that provide context about the current user and GitHub context you are operating in").
		AddReadTools(
			toolsets.NewServerTool(GetMe(getClient, t)),
		)

	// Add batch toolset for chained operations
	batch := toolsets.NewToolset("batch", "Batch execution of multiple GitHub operations").
		AddReadTools(
			toolsets.NewServerTool(GitHubBatch(getClient, getGQLClient, getRawClient, t)),
		)

	// Add toolsets to the group
	tsg.AddToolset(contextTools)
	tsg.AddToolset(repos)
	tsg.AddToolset(issues)
	tsg.AddToolset(orgs)
	tsg.AddToolset(users)
	tsg.AddToolset(pullRequests)
	tsg.AddToolset(actions)
	tsg.AddToolset(codeSecurity)
	tsg.AddToolset(secretProtection)
	tsg.AddToolset(notifications)
	tsg.AddToolset(experiments)
	tsg.AddToolset(batch)

	return tsg
}

// InitDynamicToolset creates a dynamic toolset that can be used to enable other toolsets, and so requires the server and toolset group as arguments
func InitDynamicToolset(s *server.MCPServer, tsg *toolsets.ToolsetGroup, t translations.TranslationHelperFunc) *toolsets.Toolset {
	// Create a new dynamic toolset
	// Need to add the dynamic toolset last so it can be used to enable other toolsets
	dynamicToolSelection := toolsets.NewToolset("dynamic", "Discover GitHub MCP tools that can help achieve tasks by enabling additional sets of tools, you can control the enablement of any toolset to access its tools when this toolset is enabled.").
		AddReadTools(
			toolsets.NewServerTool(ListAvailableToolsets(tsg, t)),
			toolsets.NewServerTool(GetToolsetsTools(tsg, t)),
			toolsets.NewServerTool(EnableToolset(s, tsg, t)),
		)

	dynamicToolSelection.Enabled = true
	return dynamicToolSelection
}

// ToBoolPtr converts a bool to a *bool pointer.
func ToBoolPtr(b bool) *bool {
	return &b
}
