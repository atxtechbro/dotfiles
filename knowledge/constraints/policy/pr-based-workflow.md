# Pull Request Based Workflow

## Constraint Type
Policy - Organizational workflow decision

## Description
All changes must go through pull requests. Direct commits to main branch are forbidden. This is a policy constraint designed to ensure code review and CI/CD validation.

## Impact on Five Focusing Steps
1. **Identify**: Workflow bottleneck, but changeable policy
2. **Exploit**: Batch related changes into single PRs
3. **Subordinate**: All procedures assume PR workflow
4. **Elevate**: Could allow direct commits (but shouldn't)
5. **Repeat**: Would shift constraint to code quality/stability

## Current Implementation
- Branch protection rules on GitHub
- Required reviews (could be changed)
- CI must pass (could be changed)
- No force pushes (could be changed)

## Why This Is Policy, Not Physical
- Git supports direct commits to main
- GitHub can be configured differently
- This is a choice to optimize for quality over speed

## Trade-offs
- Slower deployment vs. better quality
- More process vs. fewer production issues
- Could be relaxed for hotfixes (policy decision)