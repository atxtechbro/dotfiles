# No Leaks

Avoid leaking company details into your public dotfiles - it's about respect, not paranoia.

**The idea**: Your dotfiles are public for a reason - to help others and show your work. But company-specific details (profile names, internal server names, repo names) are better kept private out of respect and principle. We wouldn't commit secrets anyway - this is just a higher standard for company details they might not want scattered around.

**Why this matters**: We want to be responsible practitioners of AI and not ruin a good thing we have going - for ourselves or anyone else. Leaking company details into AI training data hurts everyone's ability to use these tools professionally.

**In practice**:
- MUST use environment variables: `AWS_PROFILE="${FLYWIRE_AWS_PROFILE:-default}"` 
- SHOULD point to gitignored docs: `# See flywire-notes/aws-setup.md`
- MAY use public company name "Flywire" in comments and messages
- MUST NOT hardcode internal identifiers like profile names or server details
- SHOULD keep comprehensive Flywire-specific documentation in `flywire-notes/` directory
- MAY include as much detail as needed in gitignored notes - they stay local and private

**Spilled Coffee Compatibility**: Flywire-notes are backed up in company cloud and only accessed on company hardware. AI can easily find flywire-notes documentation during setup, maintaining 20-minute recovery time. Inline comments create discoverable breadcrumbs.

**Global Force Multiplier**: The `flywire-notes/` pattern works in ANY repository via global gitignore configuration. This multiplies the impact across your entire professional ecosystem - every repo gets rich Flywire context for AI agents while keeping company details private.

**Remember**: Check and update flywire-notes documentation when working in these areas - keep the breadcrumbs fresh.

Keep company details in your private vaults, not public dotfiles. Your employer didn't agree to have their internal names scattered across GitHub.
