#!/usr/bin/env node

/**
 * Launcher for Playwright MCP server with patchright
 * 
 * This launcher ensures the official @playwright/mcp server runs
 * with patchright as the backend through npm aliasing
 */

const { spawn } = require('child_process');
const path = require('path');

// Set environment for stealth configuration
const env = {
  ...process.env,
  // Log level
  FASTMCP_LOG_LEVEL: process.env.FASTMCP_LOG_LEVEL || 'ERROR',
  // Recommended patchright configuration for stealth
  PLAYWRIGHT_LAUNCH_OPTIONS: JSON.stringify({
    channel: 'chrome',  // Use real Chrome instead of Chromium
    headless: false,    // Patchright works best in headed mode
    viewport: null,     // Don't set custom viewport
    args: [
      '--start-maximized',
      '--disable-blink-features=AutomationControlled'
    ],
    ignoreDefaultArgs: ['--enable-automation']
  })
};

// Find the mcp-server-playwright executable
const mcpExecutable = path.join(__dirname, 'node_modules', '.bin', 'mcp-server-playwright');

// Launch the MCP server
const mcpServer = spawn(mcpExecutable, process.argv.slice(2), {
  stdio: 'inherit',
  env: env,
  cwd: __dirname
});

mcpServer.on('error', (err) => {
  console.error('[patchright-mcp] Failed to start MCP server:', err);
  process.exit(1);
});

mcpServer.on('close', (code) => {
  process.exit(code || 0);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  mcpServer.kill('SIGINT');
});

process.on('SIGTERM', () => {
  mcpServer.kill('SIGTERM');
});
