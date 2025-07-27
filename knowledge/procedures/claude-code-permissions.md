# Claude Code Permissions Philosophy

Global Claude Code permissions configuration that aligns with the OSE (Outside and Slightly Elevated) principle.

These permissions enable orchestration from the right altitude - allowing agents to navigate and maintain perspective across different contexts without getting stuck in one directory. This supports the manager mindset by allowing movement between different areas of concern, enabling Claude Code to operate as an orchestrator rather than a confined worker.

## Core Permission Groups

### Navigation & Discovery
- `cd`, `ls`, `find`, `locate` - Navigate and understand project structure
- Essential for maintaining systems-level perspective

### Code Understanding  
- `grep`, `cat`, `Read` - Analyze existing code patterns
- Enables learning from the codebase before making changes

### Safe Modifications
- `Write`, `Edit`, `git add/commit` - Make controlled changes
- MCP git tools for version control operations

### System Integration
- `source` - Run setup scripts and environment configuration
- `python` - Execute analysis and utility scripts
- MCP servers - Access GitHub, filesystem, search capabilities

## Why This Matters

Without broad permissions, agents become trapped in narrow contexts. The permission set enables:
1. **Parallel work** - Multiple agents working in different areas
2. **System thinking** - Understanding the whole before changing parts
3. **Self-sufficiency** - Agents can discover what they need

This aligns with managing AI agents as a core competency rather than micromanaging individual operations.

See `knowledge/principles/ose.md` for the broader philosophy.