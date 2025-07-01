#!/usr/bin/env python3
"""Test script for local Atlassian MCP server"""

import os
import sys
import asyncio
import logging

# Set up logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Add the src directory to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'mcp/servers/atlassian-mcp-server/src'))

from mcp_atlassian.jira import JiraConfig, JiraFetcher

async def test_jira():
    """Test Jira connection and operations"""
    print("Testing Jira connection...")
    
    # Create config from environment
    try:
        config = JiraConfig.from_env()
        print(f"Config created: URL={config.url}, Auth={config.auth_type}")
        
        # Create Jira client
        jira = JiraFetcher(config)
        print("Jira client created")
        
        # Test authentication
        print("\n1. Testing authentication...")
        jira._validate_authentication()
        
        # Test get all projects
        print("\n2. Getting all projects...")
        projects = jira.get_all_projects()
        print(f"Found {len(projects)} projects")
        
        if projects:
            print(f"First project: {projects[0]}")
        
    except Exception as e:
        print(f"Error: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv(os.path.expanduser("~/.bash_secrets"))
    
    # Map ATLASSIAN_* to JIRA_* for the test
    if os.getenv("ATLASSIAN_JIRA_URL"):
        os.environ["JIRA_URL"] = os.getenv("ATLASSIAN_JIRA_URL")
    if os.getenv("ATLASSIAN_JIRA_USERNAME"):
        os.environ["JIRA_USERNAME"] = os.getenv("ATLASSIAN_JIRA_USERNAME")
    if os.getenv("ATLASSIAN_JIRA_API_TOKEN"):
        os.environ["JIRA_PERSONAL_TOKEN"] = os.getenv("ATLASSIAN_JIRA_API_TOKEN")
    
    # Enable debug logging
    os.environ["MCP_VERBOSE"] = "true"
    
    asyncio.run(test_jira())