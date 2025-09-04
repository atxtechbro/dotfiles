# MCP Servers Directory

This directory contains MCP servers and related configurations.

## Current State

As of issue #1215, git and GitHub MCP servers have been removed from this repository. The experiment (issue #1213) demonstrated that direct CLI usage via Bash tools provides better performance and reliability for git and GitHub operations.

## Lessons Learned

### What We Discovered
- **Direct CLI is faster** - Git and GitHub operations via Bash tool are more efficient than MCP server wrappers
- **Error messages are clearer** - Direct CLI provides better error reporting
- **Less complexity** - Removing MCP server layers reduces maintenance overhead
- **"Subtraction creates value"** - Sometimes removing components improves the system

### Decision Outcome
After testing (issue #1213), we determined that well-documented CLI tools like git and gh work better without MCP server wrappers. This aligns with guidance from Anthropic engineers that MCP servers add most value for custom or less-accessible tools.

## Future Direction

This directory may still be used for:
- Custom MCP servers that provide unique functionality
- Tools that don't have good CLI alternatives
- Experimental MCP server development

The removal of git/GitHub MCP servers represents a strategic simplification, focusing MCP usage where it adds unique value rather than wrapping existing CLI tools.