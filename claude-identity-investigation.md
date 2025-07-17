# Investigation: Custom Identity for Claude GitHub Actions Reactions

## Executive Summary

After thorough investigation, it is **not possible** to change the "github-actions[bot]" identity that appears when using the default `GITHUB_TOKEN` in GitHub Actions. However, there are alternative approaches using GitHub Apps that can provide a custom identity.

## Current Implementation Analysis

The current workflow at `.github/workflows/claude-pr-review.yml` uses:
- `GITHUB_TOKEN` for authentication
- `actions/github-script@v7` to create reactions
- This results in reactions appearing as "github-actions[bot]"

## Key Findings

### 1. GITHUB_TOKEN Limitations
- The `GITHUB_TOKEN` is intrinsically tied to the github-actions[bot] identity
- This identity cannot be customized or renamed
- GitHub's security model enforces this to maintain clear audit trails

### 2. GitHub App Alternative
GitHub Apps can provide custom identities and are the recommended approach:

**Advantages:**
- Custom bot name and avatar (e.g., "Claude-Bot" instead of "github-actions[bot]")
- Fine-grained permissions
- No team seat cost
- Better security than Personal Access Tokens (PATs)

**Setup Requirements:**
1. Create a GitHub App with necessary permissions
2. Generate and store private key
3. Install the app on the repository
4. Use `actions/create-github-app-token` in the workflow

### 3. Implementation Example

Here's how the workflow could be modified to use a GitHub App:

```yaml
name: Claude PR Review
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

permissions:
  contents: read
  issues: write
  pull-requests: write

jobs:
  claude-review:
    if: contains(github.event.comment.body, '@claude')
    runs-on: ubuntu-latest

    steps:
      # Generate GitHub App token
      - name: Generate app token
        id: app-token
        uses: actions/create-github-app-token@v2
        with:
          app-id: ${{ vars.CLAUDE_APP_ID }}
          private-key: ${{ secrets.CLAUDE_APP_PRIVATE_KEY }}
          
      - name: Acknowledge review request
        uses: actions/github-script@v7
        with:
          github-token: ${{ steps.app-token.outputs.token }}
          script: |
            try {
              // Add eyeball reaction - will now show as "Claude-Bot[bot]"
              const reaction = await github.rest.reactions.createForIssueComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: context.payload.comment.id,
                content: 'eyes'
              });
              
              console.log(`✅ Successfully added eyeball reaction to comment ${context.payload.comment.id}`);
              console.log(`Reaction ID: ${reaction.data.id}`);
            } catch (error) {
              console.error(`❌ Failed to add reaction: ${error.message}`);
            }

      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          token: ${{ steps.app-token.outputs.token }}

      - uses: anthropics/claude-code-action@beta
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          github_token: ${{ steps.app-token.outputs.token }}
```

## Setup Process for GitHub App

1. **Create GitHub App:**
   - Go to Settings → Developer settings → GitHub Apps → New GitHub App
   - Name: "Claude-Bot" (or similar)
   - Homepage URL: Any valid URL
   - Permissions needed:
     - Issues: Read & Write
     - Pull requests: Read & Write
     - Contents: Read
     - Reactions: Write

2. **Generate Private Key:**
   - After creation, generate a private key
   - Store as repository secret: `CLAUDE_APP_PRIVATE_KEY`

3. **Install App:**
   - Install the app on your repository
   - Note the App ID (store as repository variable: `CLAUDE_APP_ID`)

## Recommendation

**If showing "Claude" identity is important:** Implement the GitHub App approach. This requires one-time setup but provides a professional, branded appearance.

**If current functionality is sufficient:** Keep the existing implementation with github-actions[bot]. It's simpler and requires no additional configuration.

## Security Considerations

- GitHub Apps are more secure than PATs
- The app token expires after 1 hour (suitable for most workflows)
- Permissions can be fine-tuned to minimum required
- Installation can be limited to specific repositories

## Alternative Approaches Considered

1. **Personal Access Token (PAT):** Not recommended - ties actions to personal account
2. **Custom Bot Service:** Overly complex for this use case
3. **Webhooks:** Would require external infrastructure

## Conclusion

While the default GITHUB_TOKEN cannot show a custom identity, using a GitHub App is a well-supported, secure method to achieve custom bot identities in GitHub Actions. The setup complexity is moderate but provides significant branding and functionality benefits.