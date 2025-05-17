# Amazon Q Test Instructions

## Overview

This document provides instructions for running MCP integration tests using Amazon Q CLI. The primary goal is to ensure we're adding high-quality MCP servers to our dotfiles that reliably deliver their promised capabilities.

## Initial Server Verification

When running tests for any MCP integration (e.g., service-xyz):

1. **First verify the MCP server loaded successfully**. If the server fails to load, it cannot process any queries, making further testing pointless.
2. Check for initialization errors in the Amazon Q CLI output or logs.
3. Verify the server appears in the list of available MCP servers.

## Test Execution Loop

Follow this continuous improvement loop when testing:

1. Run the specified test case
2. Observe the response carefully
3. If the test fails or doesn't trigger the intended capability:
   - Diagnose the root cause (server issue, test case wording, etc.)
   - Fix the underlying issue
   - Improve the test case to more reliably trigger the capability
   - Document your changes
4. Re-run the test to verify improvement
5. Repeat until all capabilities are reliably demonstrated

## Capability Coverage

Our goal is comprehensive testing of **every capability** offered by each MCP server:

- Ensure each function/endpoint is tested with valid inputs
- Test edge cases and common failure modes
- If a capability isn't being triggered by existing tests, create new tests or modify existing ones
- Document which capabilities are covered by which tests

## Continuous Improvement

This is an iterative process focused on quality:

- Refine test cases that are ambiguous or inconsistent
- Add new test cases when gaps in coverage are identified
- Update documentation to reflect current best practices
- Share insights that could improve other MCP integrations

## Conventional Commit Format

When committing changes related to test improvements, use the following format:

```
fix(mcp-integration): resolve [specific issue] in [integration name]

Description of the issue and how it was fixed.
Tests now reliably trigger [specific capability].
```

## Test Reporting

After running tests:

1. Document which capabilities were successfully demonstrated
2. For failed capabilities, provide:
   - The exact error message or unexpected behavior
   - Steps taken to reproduce the issue
   - Your analysis of why the capability failed to trigger
   - Suggested improvements to the test case or server implementation

## Environment Setup

Before running tests, ensure:

1. The appropriate MCP server is properly installed and configured
2. Required API keys and credentials are set in `~/.bash_secrets`
3. Amazon Q CLI is updated to the latest version
4. Docker is running (for Docker-based MCP servers)
5. Network connectivity to required external services is available
