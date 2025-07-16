# No Direct Work on Main Branch

## Constraint Type
Policy - Workflow hygiene decision

## Description
Development work should never be done directly on the main branch. This is a policy constraint to prevent contamination of the primary branch and ensure clean PR diffs.

## Impact on Five Focusing Steps
1. **Identify**: Self-imposed workflow constraint
2. **Exploit**: Use feature branches for isolation
3. **Subordinate**: All dev procedures start with branch creation
4. **Elevate**: Could work on main (but creates technical debt)
5. **Repeat**: Would shift constraint to cleanup/recovery time

## Consequences of Violation
- Contaminated PR diffs (ghost commits)
- Complex git surgery to recover
- Time waste on cherry-picking
- Violates "subtraction creates value" principle

## Why This Is Policy, Not Physical
- Git allows commits on any branch
- This is a choice to optimize workflow
- Could be changed but would increase recovery work

## Enforcement
- Developer discipline
- Git hooks could enforce (another policy layer)
- Culture and code review