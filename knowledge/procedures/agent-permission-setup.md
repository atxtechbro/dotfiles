# Agent Permission Setup

Configure tool permissions when launching Amazon Q.

## Prerequisites
- Run `source setup.sh` 
- Set `WORK_MACHINE="true"` in `~/.bash_exports.local` if work machine

## Procedure
1. `qsafe` - copies untrust commands to clipboard
2. `qtrust -r` - starts Q with resume + trustall
3. Paste clipboard + Enter - applies security profile

## Result
- Productivity tools stay trusted
- Destructive tools (fs_write, execute_bash, use_aws, etc.) require explicit trust
- Permission config maintained in source control via `qsafe` alias

Hacky but functional. Will improve as client evolves.
