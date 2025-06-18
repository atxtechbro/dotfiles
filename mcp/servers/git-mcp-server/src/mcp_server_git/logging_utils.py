"""
MCP Tool Logging Utilities
Provides logging functionality for individual MCP tool calls
"""

import os
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Optional, Any
import json

MCP_TOOL_LOG = os.path.expanduser("~/mcp-tool-calls.log")
MCP_ERROR_LOG = os.path.expanduser("~/mcp-errors.log")

def log_tool_call(
    server_name: str,
    tool_name: str,
    status: str,  # "SUCCESS" or "ERROR"
    details: str,
    repo_path: Optional[Path] = None,
    parameters: Optional[dict] = None
) -> None:
    """Log an MCP tool call with detailed context"""
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    branch = "unknown"
    
    # Try to get current git branch if repo_path is provided
    if repo_path and repo_path.exists() and (repo_path / ".git").exists():
        try:
            result = subprocess.run(
                ["git", "branch", "--show-current"],
                cwd=repo_path,
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                branch = result.stdout.strip() or "unknown"
        except (subprocess.TimeoutExpired, subprocess.SubprocessError):
            branch = "unknown"
    
    # Format parameters for logging
    params_str = ""
    if parameters:
        try:
            params_str = f" | PARAMS: {json.dumps(parameters, default=str)}"
        except (TypeError, ValueError):
            params_str = f" | PARAMS: {str(parameters)}"
    
    formatted_msg = (
        f"{timestamp}: [{server_name}] TOOL_CALL: {tool_name} | "
        f"STATUS: {status} | BRANCH: {branch} | DETAILS: {details}{params_str}"
    )
    
    # Write to tool log
    try:
        with open(MCP_TOOL_LOG, "a", encoding="utf-8") as f:
            f.write(formatted_msg + "\n")
    except IOError:
        pass  # Fail silently to not break tool execution
    
    # If it's an error, also log to error log
    if status == "ERROR":
        error_msg = f"{timestamp}: [{server_name}] TOOL ERROR: {tool_name} failed - {details}"
        try:
            with open(MCP_ERROR_LOG, "a", encoding="utf-8") as f:
                f.write(error_msg + "\n")
        except IOError:
            pass

def log_tool_success(
    server_name: str,
    tool_name: str,
    details: str,
    repo_path: Optional[Path] = None,
    parameters: Optional[dict] = None
) -> None:
    """Log a successful tool call"""
    log_tool_call(server_name, tool_name, "SUCCESS", details, repo_path, parameters)

def log_tool_error(
    server_name: str,
    tool_name: str,
    error_details: str,
    repo_path: Optional[Path] = None,
    parameters: Optional[dict] = None
) -> None:
    """Log a failed tool call"""
    log_tool_call(server_name, tool_name, "ERROR", error_details, repo_path, parameters)
