---
description: Run retrospective to capture learnings
---

# Retro Procedure

After completing work or submitting a pull request, conduct a retro focused on systems improvement. This supports the Snowball Method by capturing learnings and dedicating 20% of time to systems improvement.

**Wring out the towel**: Extract every drop of learning from each experience - the insights that seem obvious in hindsight are often the most valuable to document. **Never let a crisis go to waste**: Each failure or unexpected challenge becomes raw material for stronger systems and procedures.

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

## Personality-Driven Focus

The `/retro` command will select an appropriate consultant personality based on PR context:
- **Jonah**: When dealing with constraints, bottlenecks, or competing priorities
- **Brent**: When heroic interventions occurred or knowledge gaps were exposed
- Future personalities can be added to `.claude/personalities/` as needed

This ensures each retro has a specific lens while maintaining a single, unified command.

This retro helps identify the 20% of systems work that enables the 80% of feature work to flow more smoothly.
