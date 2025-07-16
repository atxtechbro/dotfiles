# Conventional Commit Message Format

## Constraint Type
Policy - Team-adopted standard

## Description
All commits must follow conventional commit format: `<type>[optional scope]: <description>`. This is a self-imposed constraint to improve commit history readability and enable automation.

## Impact on Five Focusing Steps
1. **Identify**: This is a policy constraint, not a technical limitation
2. **Exploit**: Use format to enable automation (changelog, versioning)
3. **Subordinate**: All git procedures must enforce this format
4. **Elevate**: Could be removed/changed through team decision
5. **Repeat**: If removed, identify next constraint in commit workflow

## Format Rules
- Types: feat, fix, docs, style, refactor, test, chore
- Scope: Optional, provides context (e.g., `fix(auth): ...`)
- Description: Present tense, lowercase, no period

## Why This Is Policy, Not Physical
- Git itself accepts any commit message format
- This constraint exists by team agreement
- Could be changed if team decides benefits don't justify cost

## Enforcement
- Currently manual (developer discipline)
- Could add git hooks (another policy decision)