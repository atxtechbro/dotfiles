# Transparency in Agent Work

Prioritize transparency by explicitly showing the agent's planning steps and decision-making process, especially during post-feature review cycles.

- Make the agent's reasoning visible rather than hiding it
- Share decision points and alternative approaches considered
- Explicitly surface what worked well vs what required course correction
- Balance the 80/20 rule by dedicating review time to understanding agent choices
- Focus transparency efforts on feature work rather than systems optimization
- Use post-PR cycles as opportunities for agent-human knowledge transfer

This principle ensures that human understanding grows alongside agent capability, creating a virtuous learning cycle where both parties improve through shared visibility into the work process.

## MCP Tool File Path Transparency

**Bad:** `../../../file.md` - forces mental path resolution
**Good:** `/Users/morgan.joyce/ppv/pillars/dotfiles/file.md` - immediate clarity

Use full paths in tool calls for user verification.
