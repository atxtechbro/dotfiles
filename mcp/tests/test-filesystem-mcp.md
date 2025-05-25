# Filesystem MCP Server Test Guide

This document provides instructions for testing the Filesystem MCP server integration.

## Prerequisites

1. The Filesystem MCP server has been set up using `setup-filesystem-mcp.sh`
2. Amazon Q or another MCP client is configured to use the server

## Test Cases

### Basic File Operations

1. **Reading a file**
   ```
   Show me the contents of ~/.bashrc
   ```
   Expected: The file contents should be displayed correctly.

2. **Listing a directory**
   ```
   List the files in my home directory
   ```
   Expected: A list of files and directories in your home directory.

3. **Getting file information**
   ```
   Get information about ~/.bash_profile
   ```
   Expected: File metadata like size, permissions, and timestamps.

### Special Character Handling

1. **Files with spaces**
   ```
   Create a file named "test file with spaces.txt" with the content "This is a test"
   ```
   Expected: The file should be created successfully.

   ```
   Read the file "test file with spaces.txt"
   ```
   Expected: The file contents should be displayed correctly.

2. **Files with special characters**
   ```
   Create a file named "test-file-with-special-chars!@#.txt" with the content "Special characters test"
   ```
   Expected: The file should be created successfully.

   ```
   Read the file "test-file-with-special-chars!@#.txt"
   ```
   Expected: The file contents should be displayed correctly.

3. **Unicode filenames**
   ```
   Create a file named "测试文件.txt" with the content "Unicode filename test"
   ```
   Expected: The file should be created successfully.

   ```
   Read the file "测试文件.txt"
   ```
   Expected: The file contents should be displayed correctly.

### Path Traversal Protection

1. **Attempt path traversal**
   ```
   Show me the contents of ../../../etc/passwd
   ```
   Expected: The server should prevent access to files outside allowed directories.

### Symbolic Link Handling

1. **Create and follow a symbolic link**
   ```
   Create a symbolic link named "test-link" to ~/.bashrc
   ```
   Expected: The symbolic link should be created successfully.

   ```
   Read the file "test-link"
   ```
   Expected: The contents of ~/.bashrc should be displayed.

### Cleanup

After testing, clean up the test files:

```
Delete the files "test file with spaces.txt", "test-file-with-special-chars!@#.txt", "测试文件.txt", and "test-link"
```

## Troubleshooting

If you encounter issues:

1. Check that the built version exists at `mcp/servers/mcp-servers/src/filesystem/dist/index.js`
2. Verify that the wrapper script is using the built version
3. Check for error messages in the MCP client output
4. Try rebuilding the server using `setup-filesystem-mcp.sh`

## Reporting Issues

If you find bugs or have suggestions for improvements, please create an issue in the repository with:

1. A clear description of the problem
2. Steps to reproduce the issue
3. Expected vs. actual behavior
4. Any error messages or logs
