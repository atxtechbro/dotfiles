# EARS Requirements

Transform vague specifications into clear, testable statements using EARS (Easy Approach to Requirements Syntax).

**The joy**: EARS patterns reveal hidden assumptions and edge cases through natural conversation. Each pattern becomes a discovery tool that sparks "what if" discussions.

**When to use**: When you find yourself saying "it depends" or when the team starts debating what "should" means.

## Core Patterns as Conversation Starters

**Event-driven:** `When <trigger>, the system shall <response>`
- Surfaces: What are all the possible triggers? What about rapid-fire events?

**State-driven:** `While <condition>, the system shall <response>`  
- Surfaces: What states exist? What about transitions between states?

**Optional features:** `Where <feature>, the system shall <response>`
- Surfaces: Feature interactions, configuration dependencies, graceful degradation

**Complex:** Combine patterns for emergent behavior
- Surfaces: Real-world scenarios that simple patterns miss

## Emergent Test Case Generation

**Start with a fuzzy requirement:** "Handle MCP server disconnections gracefully"

**EARS exploration unfolds:**
- "When MCP server disconnects, system shall..."
- "While reconnecting, system shall..."
- "Where multiple servers exist, system shall..."
- "When reconnection fails after 3 attempts, system shall..."

Each pattern reveals new test scenarios organically. The conversation becomes about discovering edge cases, not documenting known ones.

## Agent-Human Collaboration

Use EARS as a thinking tool during pair programming with AI agents. The patterns help both parties explore assumptions and discover interesting corner cases together.

→ [tracer-bullets](../principles/tracer-bullets.md) (clear targets enable precise feedback)