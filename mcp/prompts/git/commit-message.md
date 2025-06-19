---
name: commit-message
description: Analyze commit patterns against principles and identify procedural gaps
context: git_log
parameters:
  - commit_count: number of recent commits to analyze (default: 100)
---

# Commit Pattern Analysis Against Principles

You are an expert at analyzing development patterns and identifying gaps between stated principles and actual practice. Based on my recent commit history, help me understand what my work patterns reveal about my priorities and where my procedures might be failing me.

## My Core Principles

**Systems Stewardship**: Maintaining and improving systems through consistent patterns, documentation, and procedures that enable sustainable growth and knowledge transfer.

**Versioning Mindset**: Progress through iteration rather than reinvention, where small strategic changes compound over time through active feedback loops.

**Subtraction Creates Value**: Strategic removal often creates more value than addition.

**Tracer Bullets**: Rapid feedback-driven development with ground truth at each step.

**Invent and Simplify**: Emphasis on simplification, malleability, usefulness, and utilitarian design.

**Do, Don't Explain**: Act like an agent, not a chatbot. Execute tasks directly rather than outputting walls of text.

**Transparency in Agent Work**: Make agent reasoning visible, especially during post-feature review cycles.

## Context

**Recent Commits (last {{commit_count}} commits):**
```
{{git_log}}
```

## Analysis Questions

1. **Principle Representation**: Which principles are over/under-represented in my commit patterns?

2. **Tension Points**: What tensions between principles show up in my work? (e.g., Do, Don't Explain vs Transparency in Agent Work)

3. **Procedural Gaps**: What procedures seem to be missing or not serving me well based on repeated patterns?

4. **Systems Stewardship Health**: Am I building sustainable, transferable knowledge or creating tribal knowledge?

5. **Iteration vs Reinvention**: Are my changes building on previous work or starting from scratch too often?

## Task

Analyze my commit patterns and provide:

1. **Principle Alignment**: Which principles are well-represented vs neglected in my actual work
2. **Hidden Tensions**: What conflicts between principles are showing up in practice
3. **Procedural Recommendations**: What new procedures or rule changes would serve me better
4. **Pattern Insights**: What does my commit history reveal about my actual priorities vs stated ones

Be direct and actionable. Focus on gaps between intention and execution.
