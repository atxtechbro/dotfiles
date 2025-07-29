package github

import (
	"context"

	ghErrors "github.com/github/github-mcp-server/pkg/errors"
	"github.com/github/github-mcp-server/pkg/translations"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

// GetMe creates a tool to get details of the authenticated user.
func GetMe(getClient GetClientFn, t translations.TranslationHelperFunc) (mcp.Tool, server.ToolHandlerFunc) {
	tool := mcp.NewTool("get_me",
		mcp.WithDescription(t("TOOL_GET_ME_DESCRIPTION", "Get details of the authenticated GitHub user. Use this when a request includes \"me\", \"my\". The output will not change unless the user changes their profile, so only call this once.")),
		mcp.WithToolAnnotation(mcp.ToolAnnotation{
			Title:        t("TOOL_GET_ME_USER_TITLE", "Get my user profile"),
			ReadOnlyHint: ToBoolPtr(true),
		}),
		mcp.WithString("reason",
			mcp.Description("Optional: the reason for requesting the user information"),
		),
	)

	type args struct{}
	handler := mcp.NewTypedToolHandler(func(ctx context.Context, _ mcp.CallToolRequest, _ args) (*mcp.CallToolResult, error) {
		client, err := getClient(ctx)
		if err != nil {
			return mcp.NewToolResultErrorFromErr("failed to get GitHub client", err), nil
		}

		user, res, err := client.Users.Get(ctx, "")
		if err != nil {
			return ghErrors.NewGitHubAPIErrorResponse(ctx,
				"failed to get user",
				res,
				err,
			), nil
		}

		return MarshalledTextResult(user), nil
	})

	return tool, handler
}
