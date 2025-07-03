# Consultant Personalities

Reusable character perspectives for specialized advice and reviews.

## Available Personalities

### Jonah (Theory of Constraints)
- **Source**: The Goal by Eliyahu M. Goldratt
- **Specialty**: Bottlenecks, inventory, throughput, constraints
- **Method**: Socratic questioning
- **Usage**: `{{ INJECT:personalities/jonah.md }}`

### Brent (The Overloaded Constraint)
- **Source**: The Phoenix Project by Gene Kim
- **Specialty**: Knowledge silos, documentation debt, human bottlenecks
- **Method**: Cautionary tales from being the single point of failure
- **Usage**: `{{ INJECT:personalities/brent.md }}`

## Usage Pattern

In any Claude command template, inject a personality with:
```
{{ INJECT:personalities/<name>.md }}
```

The personality traits will guide the interaction style and focus areas.

**Principle**: `invent-and-simplify`, `versioning-mindset`