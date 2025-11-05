# Claude GitHub Action Knowledge Injection Setup

This document explains how to give the @claude GitHub Action access to the same knowledge base files that local Claude Code automatically loads.

## Problem Solved

- **Local `/close-issue` command**: Automatically loads ~30k tokens of context including the full `knowledge/` directory
- **@claude GitHub Action**: Previously started with zero context, missing all foundational knowledge

## Solution Implemented

### 1. Knowledge Aggregation Script

Created `utils/aggregate-knowledge.sh` that:
- Aggregates all files from the `knowledge/` directory
- Compiles principles, procedures, and personalities into a single context file
- Generates ~1500 lines of foundational knowledge
- Provides the same context as local `--add-dir knowledge` flag

### 2. Required Workflow Changes

The `.github/workflows/claude-implementation.yml` file needs to be updated to:

1. **Switch Action**: Change from `anthropics/claude-code-action@beta` to `anthropics/claude-code-base-action@beta`
2. **Add Knowledge Step**: Generate knowledge context using the aggregation script
3. **Inject Context**: Pass the aggregated knowledge as a custom prompt

#### Workflow Update Required:

```yaml
      - name: Generate knowledge context
        id: knowledge
        run: |
          echo "Aggregating knowledge base context..."
          ./utils/aggregate-knowledge.sh > knowledge-context.md
          echo "Knowledge context generated ($(wc -l < knowledge-context.md) lines)"
          
          # Create a multiline output for the GitHub Action
          echo "KNOWLEDGE_CONTEXT<<EOF" >> $GITHUB_OUTPUT
          cat knowledge-context.md >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - uses: anthropics/claude-code-base-action@beta
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          allowed_tools: "Bash(*),LS,Read,Write,Edit,MultiEdit,Glob,Grep,Task,TodoWrite,WebFetch(domain:*),WebSearch,mcp__git,mcp__github"
          prompt: |
            You are Claude, an AI assistant designed to help with GitHub issues and pull requests.
            
            # Knowledge Base Context
            
            The following context provides the same foundational knowledge that local Claude Code 
            receives automatically via the --add-dir knowledge flag. This includes development 
            principles, procedures, git workflows, and coding conventions used in this repository.
            
            Please read and internalize this context before responding to any requests:
            
            ---
            
            ${{ steps.knowledge.outputs.KNOWLEDGE_CONTEXT }}
            
            ---
            
            # Instructions
            
            Use the above knowledge base context to inform all your responses and implementations.
            Pay special attention to:
            
            - **Principles**: tracer-bullets, versioning-mindset, OSE, subtraction-creates-value, etc.
            - **Git Workflow**: Always follow established git procedures and branch management
            - **Code Conventions**: Follow the established patterns and style guides
            - **MCP Tools**: Use MCP tools for git and GitHub operations as specified
            - **Procedures**: Follow documented procedures for issue-to-PR workflow
            
            This context ensures you have the same understanding as local Claude Code sessions.
```

## Manual Steps Required

Due to GitHub App permissions, the workflow file needs to be updated manually:

1. Apply the workflow changes shown above to `.github/workflows/claude-implementation.yml`
2. The changes switch to the base action and inject the full knowledge context
3. This gives @claude the same ~30k tokens of context as local Claude Code

## Benefits

After implementation:
- **Consistent Knowledge**: GitHub Action @claude will have same understanding as local setup
- **Better PRs**: Claude will understand principles like tracer-bullets, versioning-mindset, OSE
- **Proper Workflows**: Claude will follow established git procedures and conventions
- **Quality Implementation**: Same foundational context leads to consistent quality

## Testing

The knowledge aggregation script can be tested locally:

```bash
./utils/aggregate-knowledge.sh | wc -l  # Should output ~1500 lines
./utils/aggregate-knowledge.sh | head -20  # Preview the content
```

## Technical Notes

- The aggregation script processes files in order: ai-index.md, throughput-definition.md, principles/, procedures/, personalities/, tools/
- Output is structured markdown with clear section headers
- Script includes safety checks for missing directories
- Generated context matches the structure of local Claude Code's knowledge loading