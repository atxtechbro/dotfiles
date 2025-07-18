# Claude Code 64-Character Tool Name Error - Reproduction Steps

## ✅ RELIABLE MANUAL REPRODUCTION

Based on consistent manual testing, the error can be reproduced reliably with these exact steps:

### Prerequisites
- macOS system (work machine detection)
- WORK_MACHINE=true (enables all MCP servers including Atlassian)
- Clean shell environment
- Current directory: `/Users/morgan.joyce/ppv/pillars/dotfiles`

### Reproduction Steps

1. **Navigate to dotfiles directory:**
   ```bash
   cd /Users/morgan.joyce/ppv/pillars/dotfiles
   ```

2. **Start Claude Code in interactive mode:**
   ```bash
   claude
   ```
   
3. **Wait for Claude Code to initialize** (shows welcome message and MCP tool loading)

4. **Type any short input at the prompt:**
   ```
   > asa
   ```
   OR
   ```
   > test
   ```
   OR
   ```
   > help
   ```

5. **Error appears immediately:**
   ```
   ⎿  API Error: 400 tools.55.custom.name: String should have at most 64 characters
   ```

### Error Pattern Observed

- **Error Format**: `API Error: 400 tools.N.custom.name: String should have at most 64 characters`
- **Tool Numbers Seen**: 
  - `tools.55.custom.name` (most recent)
  - `tools.93.custom.name` (earlier tests)
- **Timing**: Error occurs during first user input, not during startup
- **Consistency**: 100% reproduction rate with manual interactive mode

### Key Insights

1. **Interactive Mode Required**: Error only occurs in interactive mode, not with `-p` flag
2. **First Input Trigger**: Error happens on first user input, not during initialization
3. **Tool Loading Timing**: Error suggests tool validation happens when user provides input
4. **Variable Tool Number**: Different tool numbers (55, 93) suggest dynamic loading order

### Failed Automated Reproduction Attempts

- ✅ Manual interactive mode: 100% success
- ❌ Piped input (`echo "test" | claude`): 0% success  
- ❌ Print mode (`claude -p "test"`): 0% success
- ❌ Startup without input (`claude < /dev/null`): 0% success

### Hypothesis

The error occurs during **interactive tool validation** when Claude Code:
1. Loads all MCP tools during startup
2. Validates tool names when user provides first input
3. Discovers that tool #N has a name exceeding 64 characters with internal prefixes
4. The `custom.` prefix we identified is only part of the full transformation

### Next Investigation Steps

1. **Identify Tool #55**: Determine which actual tool corresponds to position 55
2. **Find Additional Prefixes**: Discover what other transformations Claude Code applies beyond `custom.`
3. **MCP Server Analysis**: Focus on servers that might generate long tool names
4. **Interactive vs Non-Interactive**: Understand why the error only occurs in interactive mode

## Environment Details

- **OS**: macOS (Darwin)
- **WORK_MACHINE**: true
- **MCP Servers Loaded**: git, github-read, github-write, brave-search, filesystem, atlassian, gitlab
- **Total Tools**: ~156 tools across all servers
- **Directory**: `/Users/morgan.joyce/ppv/pillars/dotfiles`
