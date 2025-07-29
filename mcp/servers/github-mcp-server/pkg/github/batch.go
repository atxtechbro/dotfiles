package github

import (
	"context"
	"fmt"
	"strings"

	"github.com/github/github-mcp-server/pkg/raw"
	"github.com/github/github-mcp-server/pkg/translations"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

// toolHandlerMap is a global map to store tool handlers for batch execution
var toolHandlerMap = make(map[string]server.ToolHandlerFunc)

// RegisterToolHandler registers a tool handler for batch execution
func RegisterToolHandler(name string, handler server.ToolHandlerFunc) {
	toolHandlerMap[name] = handler
}

// GitHubBatch creates a tool to execute multiple GitHub commands in sequence.
func GitHubBatch(getClient GetClientFn, getGQLClient GetGQLClientFn, getRawClient raw.GetRawClientFn, t translations.TranslationHelperFunc) (tool mcp.Tool, handler server.ToolHandlerFunc) {
	return mcp.NewTool("github_batch",
		mcp.WithDescription(t("TOOL_GITHUB_BATCH_DESCRIPTION", "Execute multiple GitHub commands in sequence")),
		mcp.WithToolAnnotation(mcp.ToolAnnotation{
			Title: t("TOOL_GITHUB_BATCH_USER_TITLE", "Execute batch GitHub operations"),
		}),
		mcp.WithArray("commands",
			mcp.Required(),
			mcp.Description("Array of commands to execute. Each command should have 'tool' and 'args' fields"),
		),
	),
		func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
			// Get commands array from request
			commandsRaw, ok := request.GetArguments()["commands"]
			if !ok {
				return mcp.NewToolResultError("missing required parameter: commands"), nil
			}
			
			commands, ok := commandsRaw.([]interface{})
			if !ok {
				return mcp.NewToolResultError("commands must be an array"), nil
			}

			results := make([]map[string]interface{}, 0, len(commands))

			for i, cmd := range commands {
				cmdMap, ok := cmd.(map[string]interface{})
				if !ok {
					results = append(results, map[string]interface{}{
						"index":  i,
						"status": "error",
						"error":  "command must be an object with 'tool' and 'args' fields",
					})
					continue
				}

				toolName, ok := cmdMap["tool"].(string)
				if !ok {
					results = append(results, map[string]interface{}{
						"index":  i,
						"status": "error",
						"error":  "missing or invalid 'tool' field",
					})
					continue
				}

				args, ok := cmdMap["args"].(map[string]interface{})
				if !ok {
					args = make(map[string]interface{})
				}

				// Create a new tool request with the specified arguments
				toolRequest := mcp.CallToolRequest{
					Params: mcp.CallToolParams{
						Name:      toolName,
						Arguments: args,
					},
				}

				// Find the tool handler in our registry
				handler, found := toolHandlerMap[toolName]
				if !found {
					results = append(results, map[string]interface{}{
						"index":  i,
						"tool":   toolName,
						"status": "error",
						"error":  fmt.Sprintf("unknown tool: %s", toolName),
					})
					continue
				}

				// Execute the tool
				result, err := handler(ctx, toolRequest)
				if err != nil {
					results = append(results, map[string]interface{}{
						"index":  i,
						"tool":   toolName,
						"status": "error",
						"error":  err.Error(),
					})
					continue
				}

				// Extract result content
				var resultContent string
				if len(result.Content) > 0 {
					if textContent, ok := result.Content[0].(mcp.TextContent); ok {
						resultContent = textContent.Text
					} else {
						resultContent = fmt.Sprintf("%v", result.Content[0])
					}
				}

				results = append(results, map[string]interface{}{
					"index":  i,
					"tool":   toolName,
					"status": "success",
					"result": resultContent,
				})
			}

			// Format results for display
			var formattedResults []string
			successCount := 0
			for _, r := range results {
				if r["status"] == "success" {
					successCount++
					formattedResults = append(formattedResults, 
						fmt.Sprintf("✓ %s: %v", r["tool"], r["result"]))
				} else {
					formattedResults = append(formattedResults, 
						fmt.Sprintf("✗ %s: %v", r["tool"], r["error"]))
				}
			}

			summary := fmt.Sprintf("Batch executed: %d/%d succeeded\n\n%s", 
				successCount, len(results), 
				strings.Join(formattedResults, "\n"))

			return mcp.NewToolResultText(summary), nil
		}
}