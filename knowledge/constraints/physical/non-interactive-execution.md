# Non-Interactive Execution Only

You (Claude) ARE the interactive session. You literally CANNOT provide interactive input to any command.

**Rule**: NEVER run commands that expect input. Use flags: `claude -p`, `git commit -m`, `npm install -y`, `apt-get -y`.

Interactive commands violate OSE - they pull you down from orchestration to waiting for input that will never come.