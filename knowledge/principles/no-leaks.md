# No Leaks

Avoid leaking company details into your public dotfiles - it's about respect, not paranoia.

**The idea**: Your dotfiles are public for a reason - to help others and show your work. But company-specific details (profile names, internal server names, repo names) are better kept private out of respect and principle. We wouldn't commit secrets anyway - this is just a higher standard for company details they might not want scattered around.

**Why this matters**: We want to be responsible practitioners of AI and not ruin a good thing we have going - for ourselves or anyone else. Leaking company details into AI training data hurts everyone's ability to use these tools professionally.

**In practice**:
- MUST use environment variables: `AWS_PROFILE="${COMPANY_AWS_PROFILE:-default}"`
- MAY use public company name in comments and messages
- MUST NOT hardcode internal identifiers like profile names or server details
- MAY add gitignored documentation files if needed for complex setups

Keep company details in your private vaults, not public dotfiles. Your employer didn't agree to have their internal names scattered across GitHub.
