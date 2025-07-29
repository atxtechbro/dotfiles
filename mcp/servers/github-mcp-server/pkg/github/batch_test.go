package github

import (
	"context"
	"testing"

	"github.com/github/github-mcp-server/pkg/raw"
	"github.com/github/github-mcp-server/pkg/translations"
	"github.com/google/go-github/v72/github"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/shurcooL/githubv4"
	"github.com/stretchr/testify/assert"
)

func TestGitHubBatch(t *testing.T) {
	ctx := context.Background()
	
	// Mock functions
	getClient := func(ctx context.Context) (*github.Client, error) {
		return nil, nil
	}
	getGQLClient := func(ctx context.Context) (*githubv4.Client, error) {
		return nil, nil
	}
	getRawClient := func(ctx context.Context) (*raw.Client, error) {
		return nil, nil
	}
	translator := translations.NullTranslationHelper

	// Register mock tool handlers
	RegisterToolHandler("test_tool1", func(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		return mcp.NewToolResultText("Result from tool1"), nil
	})
	RegisterToolHandler("test_tool2", func(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		return mcp.NewToolResultText("Result from tool2"), nil
	})

	// Create the batch tool
	tool, handler := GitHubBatch(getClient, getGQLClient, getRawClient, translator)

	// Verify tool properties
	assert.Equal(t, "github_batch", tool.Name)
	assert.NotNil(t, handler)

	t.Run("successful batch execution", func(t *testing.T) {
		// Create a batch request
		request := mcp.CallToolRequest{
			Params: mcp.CallToolParams{
				Name: "github_batch",
				Arguments: map[string]interface{}{
					"commands": []interface{}{
						map[string]interface{}{
							"tool": "test_tool1",
							"args": map[string]interface{}{},
						},
						map[string]interface{}{
							"tool": "test_tool2",
							"args": map[string]interface{}{},
						},
					},
				},
			},
		}

		result, err := handler(ctx, request)
		assert.NoError(t, err)
		assert.NotNil(t, result)
		
		// Check that the result contains success message
		assert.Contains(t, result.Content[0].(mcp.TextContent).Text, "Batch executed: 2/2 succeeded")
		assert.Contains(t, result.Content[0].(mcp.TextContent).Text, "✓ test_tool1: Result from tool1")
		assert.Contains(t, result.Content[0].(mcp.TextContent).Text, "✓ test_tool2: Result from tool2")
	})

	t.Run("handles invalid command format", func(t *testing.T) {
		request := mcp.CallToolRequest{
			Params: mcp.CallToolParams{
				Name: "github_batch",
				Arguments: map[string]interface{}{
					"commands": []interface{}{
						"invalid_command", // Not a map
					},
				},
			},
		}

		result, err := handler(ctx, request)
		assert.NoError(t, err)
		assert.NotNil(t, result)
		assert.Contains(t, result.Content[0].(mcp.TextContent).Text, "Batch executed: 0/1 succeeded")
		assert.Contains(t, result.Content[0].(mcp.TextContent).Text, "command must be an object")
	})

	t.Run("handles unknown tool", func(t *testing.T) {
		request := mcp.CallToolRequest{
			Params: mcp.CallToolParams{
				Name: "github_batch",
				Arguments: map[string]interface{}{
					"commands": []interface{}{
						map[string]interface{}{
							"tool": "unknown_tool",
							"args": map[string]interface{}{},
						},
					},
				},
			},
		}

		result, err := handler(ctx, request)
		assert.NoError(t, err)
		assert.NotNil(t, result)
		assert.Contains(t, result.Content[0].(mcp.TextContent).Text, "Batch executed: 0/1 succeeded")
		assert.Contains(t, result.Content[0].(mcp.TextContent).Text, "unknown tool: unknown_tool")
	})

	t.Run("handles missing commands parameter", func(t *testing.T) {
		request := mcp.CallToolRequest{
			Params: mcp.CallToolParams{
				Name:      "github_batch",
				Arguments: map[string]interface{}{},
			},
		}

		result, err := handler(ctx, request)
		assert.NoError(t, err)
		assert.NotNil(t, result)
		assert.True(t, result.IsError)
		assert.Contains(t, result.Content[0].(mcp.TextContent).Text, "missing required parameter: commands")
	})
}