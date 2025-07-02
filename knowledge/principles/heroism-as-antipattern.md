# Heroism as Antipattern

The impulse to be a "macho hero" through one-off fixes and firefighting is counterproductive. Reject heroics in favor of systematic solutions.

- **No firefighting**: Address root causes, not symptoms
- **No one-offs**: Every fix should be embedded in setup scripts or procedures
- **No manual heroics**: If it's not automated or documented, it's not done
- **Scalable over impressive**: Prioritize solutions that compound over time

**Examples of heroism (avoid these):**
- Manually copying files instead of using symlinks in setup scripts
- Quick patches that "fix it for now" without documentation
- Solving problems through memory rather than procedures
- **Manual symlinking**: Running `ln -s source target` in terminal instead of adding to setup script
- **Ad-hoc file moves**: Using `mv file.json new/location/` without updating setup automation
- **One-off permission fixes**: Running `chmod 600 ~/.secrets` manually instead of in script
- **Quick config edits**: Manually editing `.gitconfig` instead of using `git config` in scripts
- **Directory creation**: Running `mkdir -p ~/some/path` instead of ensuring scripts create needed dirs
- **Manual downloads**: Using `curl` or `wget` directly instead of adding to installation scripts
- **Environment variable exports**: Setting `export VAR=value` in terminal instead of `.bash_exports`
- **Service restarts**: Running `systemctl restart service` manually instead of automating in scripts

**Real-world failures from manual heroics:**
- **The forgotten symlink**: "Why isn't Claude Code finding my MCP config?" → Someone ran `ln -s` manually on their machine but never added it to setup
- **The permission mystery**: "My secrets file works on my laptop but not on the new machine" → `chmod 600` was done manually, not in script
- **The missing directory**: "Script fails with 'directory not found'" → Parent directory was created with `mkdir` but not added to setup
- **The config drift**: "Why do I have different Git settings on different machines?" → Manual `.gitconfig` edits instead of scripted `git config`
- **The lost download**: "Where did that tool installer go?" → Downloaded with `curl` to `/tmp`, now gone after reboot

**Instead, embrace:**
- Hardened, embedded solutions that survive the "spilled coffee test"
- Source-controlled fixes that scale
- Systems that grow stronger with each iteration
- **Every terminal command that changes state should become code**
- **If you type it twice, script it once**

**The litmus test**: Can you destroy your laptop, get a new one, run `git clone && ./setup.sh`, and be back to exactly where you were? If not, you've been a hero instead of a steward.

This principle mandates both human and AI agents to resist the temptation of quick heroic fixes in favor of sustainable systems.