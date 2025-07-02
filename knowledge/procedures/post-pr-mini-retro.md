# Post-PR Mini Retro

After submitting a pull request for feature-related workflows, conduct a mini retro focused on systems improvement. This supports the Snowball Method by capturing learnings and dedicating 20% of time to systems improvement.

## IMPORTANT: Agent-Led Collaborative Process

**The agent drives the retro while actively inviting human participation:**

1. **Agent creates a retro plan**: Think through the implementation, identify key moments, and structure the discussion
2. **Agent invites human in**: Present your plan and explicitly invite the human to participate
3. **Agent leads with substance**: Share your genuine reflections, tensions observed, and questions you have
4. **Human adds perspective**: The human provides input where they have insights or corrections
5. **Collaborative discussion**: Both parties explore insights together
6. **Human confirms completion**: The human explicitly confirms when the retro is complete

The agent should:
- Start with something like: "I've been reflecting on our implementation. Here's my retro plan... [plan]. Let's work through this together."
- Share real observations and questions, not just run through a checklist
- Be specific about decision points and tensions noticed
- Genuinely seek the human's perspective on key moments

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

## Specialized Review Selection

After the general retro, the agent should select ONE specialized review to run based on the PR context:

**Available Specialized Reviews:**
- `/inventory-reduction-retro` - When dealing with backlog, cognitive load, or too many open loops
- `/documentation-debt-review` - When heroic interventions occurred or knowledge gaps were exposed

**Selection Process:**
1. Agent analyzes the PR and retro discussion
2. Picks the most relevant specialized review
3. Explains: "Based on [specific observation], I think we should run [review type] because [reasoning]"
4. Runs the selected review as a focused follow-up

**Selection Criteria Examples:**
- Many ad-hoc decisions → documentation-debt-review
- Struggled with priorities → inventory-reduction-retro
- Knowledge gaps exposed → documentation-debt-review
- Too many competing concerns → inventory-reduction-retro

This ensures specialized reviews get used when relevant, not just created and forgotten.

This retro helps identify the 20% of systems work that enables the 80% of feature work to flow more smoothly.
