# Amazon Q Developer GitHub Integration Setup

## Why This Integration

Assign GitHub issues to an AI agent that automatically implements solutions and creates pull requests for human review.

GitHub organization admin access required, AWS account not required.

<details>
<summary>For GitHub Enterprise with IP Allowlisting</summary>

If your GitHub enterprise organization has enabled IP allowlisting, you must accept these IP addresses:
- 34.228.181.128
- 44.219.176.187
- 54.226.244.221

You can manually add these to your allow list or choose to automatically add them during installation. See [GitHub's IP allowlisting documentation](https://docs.github.com/en/enterprise-cloud@latest/admin/configuration/configuring-your-enterprise/restricting-network-traffic-to-your-enterprise-with-an-ip-allow-list) for more details.

</details>

## Installation Mechanics

1. Install Amazon Q Developer GitHub App from marketplace: https://github.com/marketplace/amazon-q-developer - Click "Install it for free" (as of 2025-06-21, this is the only pricing plan available)

2. Complete order processing page (shows $0.00 total for free plan, payment method may be required even for free items) - Click "Complete order and begin installation"

3. Configure installation: Choose repository access ("All repositories" or "Only select repositories" - select as needed). Permissions are fixed and not configurable:
   • Read access to administration and metadata
   • Read and write access to actions, checks, code, issues, pull requests, and workflows
   Click green "Install" button

4. Installation complete - You will be automatically taken to summary page showing "Okay, Amazon Q Developer was installed on the @[your-username] account." with app details, permissions summary, and repository access configuration

## The Fun Part

### Issue-to-PR Generation
1. Go to your GitHub issues backlog or create a new issue
2. Add the **Amazon Q development agent** label (🟦 Blue) - this signals the agent to generate new features or iterate code based on issue descriptions and comments
3. Amazon Q bot will automatically comment on the issue confirming it's starting work and will open a pull request when complete
4. Bot updates its comment when finished: "✅ I finished the proposed code changes, and the pull request is ready for review: #[PR-number]. Comment on the pull request to provide feedback and request a new iteration."

### Automatic Code Reviews
Amazon Q Developer also automatically reviews pull requests (created by humans) for security vulnerabilities and code quality issues, commenting: "⏳ I'm reviewing this pull request..." followed by "✅ I finished the code review, and didn't find any security or code quality issues." Note: By default, it appears to review the initial PR but may not re-review after subsequent pushes. Code reviews can be disabled during the AWS registration process.

## Optional Next Steps
You can increase your free usage at any time by registering your Amazon Q Developer app installation with your AWS account. During this registration process, you can choose to disable code reviews, but feature development and code transformation are always enabled.
