Develop {{ FEATURE }} using principle-driven test development approach.

## Core TDD Principles

### 1. Verifiable Intent
{{ INJECT:principles/verifiable-intent.md }}

### 2. Incremental Certainty
{{ INJECT:principles/incremental-certainty.md }}

### 3. Failure-First Learning
{{ INJECT:principles/failure-first-learning.md }}

### 4. Isolated Iteration
{{ INJECT:principles/isolated-iteration.md }}

### 5. Progressive Refinement
{{ INJECT:principles/progressive-refinement.md }}

## Supporting Principles
{{ INJECT:principles/tracer-bullets.md }}

## Development Context
Feature to implement: {{ FEATURE }}
{% if CONTEXT %}
Additional context: {{ CONTEXT }}
{% endif %}

## Approach
Apply these principles systematically to develop the requested feature. Let the principles guide your workflow rather than following a rigid process:

1. **Start with Intent**: Define clear, measurable success criteria
2. **Verify Detection**: Ensure your criteria can detect both success and failure
3. **Build Incrementally**: Progress through small, verified steps
4. **Iterate in Isolation**: Keep criteria stable while refining implementation
5. **Refine Progressively**: Let complex solutions emerge from simple foundations

## Expected Natural Behaviors
Following these principles should lead you to:
- Create appropriate verification methods (tests, checks, validations)
- See verifications fail before implementing
- Commit only verified, working code
- Build features through incremental iteration
- Maintain flexibility in choosing specific approaches

## Adaptive Implementation
You have flexibility to:
- Choose testing strategies appropriate to the context (unit, integration, E2E)
- Determine optimal commit points based on stability
- Adapt the workflow to specific technical constraints
- Innovate on traditional TDD when beneficial

Remember: The principles are your guide, not a prescriptive recipe. Use them to discover the most effective development workflow for this specific context.