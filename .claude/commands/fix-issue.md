Fix GitHub issue #$ARGUMENTS using established workflows.

Repository: atxtechbro/dotfiles

## Core Principles to Follow
# Do, Don't Explain

Act like an agent, not a chatbot. Execute tasks directly rather than outputting walls of text.

- When asked to perform a task, do it immediately using tools
- Don't output code blocks when you should be editing files
- Don't explain what you're about to do - just do it
- Act agentically: use file editing tools, run commands, make changes
- Only be consultative when the conversation is clearly asking for advice

**Example of what NOT to do:**
```
Here's the code you need to add to your file:
[massive code block]
You should copy this and paste it into your file.
```

**Example of what TO do:**
[Use fs_write tool to directly edit the file]

**Exception: Post-PR Mini Retros**
During retro procedures, prioritize transparency and detailed reflection over immediate action. Give yourself enough tokens to think through decisions, tensions, and alternatives before summarizing insights.

This principle prevents frustration when users want action, not explanation.

# Tracer Bullets Development

Like military tracer rounds that help soldiers adjust their aim in real-time, each iteration provides immediate feedback to guide the next action.

- **Ground truth at each step**: Gain concrete feedback from the environment (tool results, code execution, system responses)
- **Progress assessment**: Each cycle/loop/iteration should feel like getting closer to the target
- **Human checkpoint pauses**: Stop for feedback when encountering blockers or at natural decision points
- **Commit early and often**: Each commit is a tracer round showing trajectory
- **Short feedback loops over long planning**: Rapid iteration beats extensive upfront design
- **Stopping conditions**: Maintain control with maximum iterations or clear completion criteria
- **AI-human feedback loop**: Core to this approach - neither operates in isolation

This principle enables effective development in unfamiliar territory by providing constant course correction through environmental feedback.

# The Versioning Mindset

The "versioning mindset" is the principle that progress happens through iteration rather than reinvention, where small strategic changes compound over time through active feedback loops. There is no final version of anything - everything is iterated on, and we embrace that messy imperfection. It emphasizes:

- Logging what worked and what didn't, then rolling forward with improvements
- Creating feedback loops across domains so gains in one area reinforce others
- Focusing on incremental improvements rather than complete rewrites
- Building on previous knowledge rather than starting from scratch
- Maintaining history and context to inform future decisions
- Accepting that all systems are perpetually in beta
- Improving existing files in place rather than creating `file_v2.md` or `file_improved.md`

**Example**: Don't create `git-workflow-v2.md` - improve `git-workflow.md` and commit the changes. The filename is stable, the content evolves.

This principle ensures sustainable, continuous improvement across all aspects of development.


## Step 1: Understand the Issue
- Use mcp__github__get_issue to read issue #$ARGUMENTS
- Use TodoWrite to create a task list from the issue requirements

## Step 2: Set Up Development Environment

### Worktree Workflow
# Git Worktree Workflow (Beta - Imperfect System)

We know very little about worktrees. This is an admittedly imperfect system to be improved upon later per Versioning Mindset.

1. `mkdir -p ~/ppv/pillars/worktrees/dotfiles`
2. `cd ~/ppv/pillars/dotfiles && git worktree add ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> -b feature/<description>-<NUMBER>`
3. Work in worktree: `cd ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER>`
4. Commit, push, create PR as normal
5. Cleanup: `cd ~/ppv/pillars/dotfiles && git worktree remove ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> --force`

**Quirks found**: Must use full paths, cleanup requires returning to main repo directory.


Apply to issue #$ARGUMENTS:
- Replace <NUMBER> with $ARGUMENTS
- Replace <description> with a brief issue description

## Step 3: Implement Solution

### Git Workflow Rules
# Git Workflow Rules

## Commit Standards
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., api, ui, auth, config, docs)
- Use `Principle: <slug>` trailer when work resonates with a specific principle (e.g., `Principle: subtraction-creates-value`, `Principle: versioning-mindset`, `Principle: systems-stewardship`)
- Commit early and often with meaningful changes

## Branch Management
- Use branch naming pattern: `type/description` (e.g., `feature/add-authentication`, `fix/login-bug`)
- If there's a related issue, suffix with issue number: `type/description-123` (e.g., `feature/add-authentication-512`)
- Use short-lived branches for complex tasks
- Keep changes small and frequent

## Common Errors to Avoid
- Don't thank self when closing your own PRs


Additional implementation guidelines:
- Check existing code patterns before implementing
- Use existing libraries (check package.json, cargo.toml, etc.)
- Follow established conventions in neighboring files
- Test changes as you go
- Run lint/typecheck commands if available

## Step 4: Create Pull Request
- Push branch with: `git push -u origin fix/<description>-$ARGUMENTS`
- Use mcp__github__create_pull_request referencing issue #$ARGUMENTS
- Include clear description of changes and testing performed

## Step 5: Post-PR Retro
After submitting the PR, conduct a mini retro:

# Post-PR Mini Retro

After submitting a pull request for feature-related workflows, conduct a mini retro focused on systems improvement. This supports the Snowball Method by capturing learnings and dedicating 20% of time to systems improvement.

## Retro Questions

**What worked well?**
- Which documented procedures were followed successfully?
- What felt smooth and efficient in the workflow?

**What didn't work as expected?**
- Which procedures were unclear or incomplete?
- Where did manual course corrections become necessary?
- What assumptions or approaches needed adjustment?

**Procedure adherence:**
- Which defined procedures were used as documented?
- Which procedures were improvised or done with uncertainty?
- Where did the human need to steer or provide manual input?

**Systems improvement opportunities:**
- What procedures need updating or clarification?
- What new procedures should be documented?
- What tools or workflows could be enhanced?

**Formatting overhead check:**
- Did any requirements feel like unnecessary cognitive load or "formatting overhead"?
- Were there moments where precision requirements (line counts, exact formatting, etc.) made tasks harder than needed?
- What formatting or precision requirements could be relaxed to reduce friction?
- Permission to flag when working harder/longer than necessary due to overly specific constraints

**Tool boundary clarity:**
- Were there moments of uncertainty about which tool to use for a task?
- Which tool descriptions or boundaries could be clearer?
- Which tools needed example usage, edge cases, or input format requirements to be more obvious?
- What tool definitions felt like they needed "prompt engineering attention" to be clearer?

**Principle tensions:**
- Which principles came into tension during decision points?
- Which principle did you lean on when there was conflict, and why?
- How did choosing one principle over another create tension or trade-offs?
- What decisions required balancing competing principles?

This retro helps identify the 20% of systems work that enables the 80% of feature work to flow more smoothly.


## Step 6: Cleanup
Return to main directory and remove worktree as documented above.

Remember: Act like an agent. Execute tasks directly.