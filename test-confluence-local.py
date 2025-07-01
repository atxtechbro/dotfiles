#!/usr/bin/env python3
"""Test script for local Confluence MCP server"""

import os
import sys
import asyncio
import logging

# Set up logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Add the src directory to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'mcp/servers/atlassian-mcp-server/src'))

from mcp_atlassian.confluence import ConfluenceConfig, ConfluenceFetcher

async def test_confluence():
    """Test Confluence connection and operations"""
    print("Testing Confluence connection...")
    
    # Create config from environment
    try:
        config = ConfluenceConfig.from_env()
        print(f"Config created: URL={config.url}, Auth={config.auth_type}")
        
        # Create Confluence client
        confluence = ConfluenceFetcher(config)
        print("Confluence client created")
        
        # Test authentication
        print("\n1. Testing authentication...")
        confluence._validate_authentication()
        
        # Test get all spaces
        print("\n2. Getting all spaces...")
        spaces = confluence.get_all_spaces(limit=5)
        print(f"Found {len(spaces)} spaces")
        
        if spaces:
            print(f"First space: {spaces[0]}")
        
    except Exception as e:
        print(f"Error: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv(os.path.expanduser("~/.bash_secrets"))
    
    # Map ATLASSIAN_* to CONFLUENCE_* for the test
    if os.getenv("ATLASSIAN_CONFLUENCE_URL"):
        os.environ["CONFLUENCE_URL"] = os.getenv("ATLASSIAN_CONFLUENCE_URL")
    if os.getenv("ATLASSIAN_CONFLUENCE_USERNAME"):
        os.environ["CONFLUENCE_USERNAME"] = os.getenv("ATLASSIAN_CONFLUENCE_USERNAME")
    if os.getenv("ATLASSIAN_CONFLUENCE_API_TOKEN"):
        os.environ["CONFLUENCE_PERSONAL_TOKEN"] = os.getenv("ATLASSIAN_CONFLUENCE_API_TOKEN")
    
    # Enable debug logging
    os.environ["MCP_VERBOSE"] = "true"
    
    asyncio.run(test_confluence())