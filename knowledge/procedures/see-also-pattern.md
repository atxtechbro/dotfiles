# See Also Pattern

A standardized approach for creating bidirectional links between related concepts in our knowledge base, similar to Notion's backlinks or Wikipedia's "See also" sections.

## When to Use

Add a "See Also" section when:
- Two concepts are philosophically related (e.g., Jonah personality ↔ throughput definition)
- One concept implements or embodies another (e.g., a procedure that implements a principle)
- Understanding one concept enhances understanding of another
- There's a source material relationship (e.g., concepts derived from the same book)

## Format

Always place the "See Also" section at the end of the document, after all main content:

```markdown
## See Also
- [Link Text](relative/path/to/file.md) - Brief description of why this is related
- External Resource Name - Context for external references
```

## Guidelines

1. **Make it bidirectional**: If A links to B, then B should link back to A
2. **Use relative paths**: Enable navigation regardless of where the repo is cloned
3. **Add context**: Include a brief description of the relationship
4. **Keep it focused**: Only link truly related concepts, not everything tangentially connected
5. **Update both files**: When adding a link, always update both ends of the relationship

## Examples

**In a principle file:**
```markdown
## See Also
- [Git Workflow](../procedures/git-workflow.md) - Procedure that implements this principle
- [Jonah Personality](../personalities/jonah.md) - Consultant persona that teaches this concept
```

**In a personality file:**
```markdown
## See Also
- [Throughput Definition](../../knowledge/throughput-definition.md) - The North Star principle this persona helps discover
- The Goal by Eliyahu M. Goldratt - Source material for this persona
```

## Benefits

- Creates a knowledge graph for navigating related concepts
- Reduces duplication by linking rather than repeating
- Helps discover connections between ideas
- Enables both human browsing and potential future tooling

This pattern supports the [Systems Stewardship](../principles/systems-stewardship.md) principle by creating consistent, maintainable knowledge structures.