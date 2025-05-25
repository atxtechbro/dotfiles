# MCP Server Tests

This directory contains tests for the MCP servers in this repository.

## Test Structure

- `lib/test-harness.sh`: Common test functions and utilities
- `test-*-mcp.md`: Manual test documentation for each MCP server
- `test-*-mcp.sh`: Automated test scripts for each MCP server

## Running Tests

To run tests for a specific MCP server:

```bash
# Run Git MCP server tests with Amazon Q
./test-git-mcp.sh

# Run with a different model (if supported)
TEST_MODEL=claude ./test-git-mcp.sh
```

## Test Harness

The test harness provides common functions for all test scripts:

- `run_test`: Run a test with a command and expected output pattern
- `skip_test`: Skip a test with a reason
- `init_test_suite`: Initialize a test suite with a name
- `print_summary`: Print a summary of test results

## Adding New Tests

1. Create a new test script based on the existing ones
2. Source the common test harness
3. Define tests using `run_test` and `skip_test` functions
4. Add cleanup code if needed

Example:

```bash
#!/bin/bash

# Source the common test harness
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/test-harness.sh"

# Initialize test suite
init_test_suite "MY MCP SERVER"

# Run tests
run_test "Test Name" "Command to run" "expected|output|pattern"

# Print summary
print_summary
```

## Future Improvements

- Support for more AI models
- Parameterized testing
- Test result reporting and visualization
- Integration with CI/CD pipelines
