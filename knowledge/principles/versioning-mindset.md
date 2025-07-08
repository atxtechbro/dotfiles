# The Versioning Mindset (VM)

The "versioning mindset" is the principle that progress happens through iteration rather than reinvention, where small strategic changes compound over time through active feedback loops. There is no final version of anything - everything is iterated on, and we embrace that messy imperfection. It emphasizes:

- Logging what worked and what didn't, then rolling forward with improvements
- Creating feedback loops across domains so gains in one area reinforce others
- Focusing on incremental improvements rather than complete rewrites
- Building on previous knowledge rather than starting from scratch
- Maintaining history and context to inform future decisions
- Accepting that all systems are perpetually in beta
- Improving existing files in place rather than creating `file_v2.md` or `file_improved.md`

**Relationship to abstraction:**
VM prioritizes making code malleable through the right level of abstraction. Not too specific (hardcoded), not too clever (over-engineered). The sweet spot where code can evolve.

**Knowledge Decay Pattern:**
- Knowledge doesn't rust like physical inventory, it becomes outdated or constraining
- Flexible systems sometimes mean having less system, not more
- Provider-agnostic approaches as manufacturing flexibility

**Subtraction as Iteration:**
Removing code, features, or documentation IS iteration. Each commit—whether adding or removing—moves the system forward. See also: [Subtraction Creates Value](subtraction-creates-value.md).

**Example progression:**
1. Hardcoded solution for specific use case
2. Discover patterns through use
3. Abstract to cover more scenarios
4. Keep iterating based on actual needs

**Semantic Compression Hierarchy:**
When evolving systems, prefer: **Replace > Append > Add**
- Replace: Transform existing tools/commands for new purposes (e.g., `/retro` → `/inventory-cleanup`)
- Append: Add capabilities to existing structures
- Add: Create new structures only when necessary

**Example**: Don't create `git-workflow-v2.md` - improve `git-workflow.md` and commit the changes. The filename is stable, the content evolves.

This principle ensures sustainable, continuous improvement across all aspects of development.
