# Close Issue Procedure

The authoritative procedure for implementing GitHub issues.

**The implementation template IS the documentation.**

**See the actual implementation:**
- Template: `.github/workflow-prompts/issue-implementation.md`
- Knowledge aggregation: `.github/scripts/aggregate-knowledge.sh`

**When to use**: Processing any GitHub issue with /close-issue or @claude

Both workflows use the same template:
- `/close-issue` command: Injects template with preloaded knowledge
- `@claude` GitHub Action: Injects template with aggregated knowledge

The template defines the entire workflow - what you read is what runs.

**Detailed guide**: See [close-issue-guide.md](/.github/ISSUE_TEMPLATE/close-issue-guide.md) for decision matrices and edge cases.