# Amazon Q Test Instructions

## Overview

This document provides instructions for running MCP integration tests using Amazon Q CLI. When running these tests, follow the guidelines below to ensure consistent and reliable results.

## Test Execution Guidelines

1. Run the tests exactly as specified in the test case files
2. Address any failures according to the rules in the root project's documentation
3. Follow conventional commit practices when making changes to fix test failures
4. Document any unexpected behavior or edge cases discovered during testing

## Conventional Commit Format

When committing changes related to test failures, use the following format:

```
fix(mcp-integration): resolve [specific issue] in [integration name]

Description of the issue and how it was fixed.
Tests now pass with [specific behavior].
```

## Test Reporting

After running tests:

1. Document which tests passed and which failed
2. For failed tests, provide:
   - The exact error message or unexpected behavior
   - Steps taken to reproduce the issue
   - Any environment-specific factors that might be relevant

## Environment Setup

Before running tests, ensure:

1. The appropriate MCP server is properly installed and configured
2. Required API keys and credentials are set in `~/.bash_secrets`
3. Amazon Q CLI is updated to the latest version
4. Docker is running (for Docker-based MCP servers)
