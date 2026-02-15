# Python REPL MCP Server

This integration provides a Python REPL (Read-Eval-Print Loop) as an MCP server, allowing you to execute Python code through the Model Context Protocol with a persistent session.

## Features

- **Persistent Python Session**: Variables persist between executions
- **Environment Variables**: Support for .env files
- **Package Management**: Install packages directly from PyPI
- **Project Management**: Create timestamped project directories
- **File Operations**: Create and load files within the REPL
- **Comprehensive Logging**: Logs stored in the logs directory

## Setup

The setup script (`setup-python-mcp.sh`) handles all installation and configuration:

```bash
# Run the setup script
./mcp/setup-python-mcp.sh
```

## Usage with Amazon Q CLI

Add the following to your Amazon Q configuration:

```json
{
  "mcpServers": {
    "python-repl": {
      "command": "py-mcp-start"
    }
  }
}
```

## Available Tools

Based on the actual source code, the following tools are available:

1. `execute_python`: Execute Python code with persistent variables
   - `code`: Python code to execute
   - `reset`: Optional boolean to reset the session (default: false)

2. `list_variables`: Show all variables in the current session

3. `install_package`: Install a package from PyPI using `uv`
   - `package`: Name of the package to install

4. `initialize_project`: Create a new project directory with timestamp prefix
   - `project_name`: Name for the project directory

5. `create_file`: Create a new file with specified content
   - `filename`: Path to the file (supports nested directories)
   - `content`: Content to write to the file

6. `load_file`: Load and execute a Python script in the current session
   - `filename`: Path to the Python script to load

## Examples

Initialize a new project:

```python
# Create a new project directory
initialize_project("data_analysis")
```

Create and execute a script:

```python
# Create a new Python file
create_file("script.py", """
def greet(name):
    return f"Hello, {name}!"
""")

# Load and execute the script
load_file("script.py")

# Use the loaded function
print(greet("World"))
```

Install and use a package:

```python
# Install pandas
install_package("pandas")

# Use the installed package
import pandas as pd
df = pd.DataFrame({'A': [1, 2, 3]})
print(df)
```

List all variables:

```python
# Show all variables in the current session
list_variables()
```

Reset the session:

```python
# Use execute_python with reset=true to clear all variables
execute_python("", reset=True)
```

## Environment Variables

The server supports `.env` file for environment variables management. Create a `.env` file in the mcp-python directory to store your environment variables. These variables will be automatically loaded and accessible in your Python REPL session using:

```python
import os

# Access environment variables
my_var = os.environ.get('MY_VARIABLE')
# or
my_var = os.getenv('MY_VARIABLE')
```

## Alignment with Dotfiles Philosophy

This integration follows our core principles:

1. **The Spilled Coffee Principle**: Easy setup and recovery with a single script
2. **The Snowball Method**: Persistent REPL session accumulates knowledge over time
3. **The Versioning Mindset**: Supports incremental improvements through file operations
