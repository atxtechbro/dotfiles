# Self-Hosted Runner Security for Public Repositories

Critical security considerations when using self-hosted runners with public repos.

## ⚠️ IMPORTANT: Logs Are Always Public

**GitHub Actions logs are ALWAYS publicly visible for public repositories**. You cannot disable this. Anyone can view:
- All console output from your workflows
- Error messages that might reveal system paths
- Environment details printed by commands
- Any data your scripts output

## Security Risks

### 1. Information Disclosure
- **System paths**: Commands might reveal directory structures
- **Usernames**: Git configs, file paths might contain usernames  
- **Environment**: OS details, installed software versions
- **Network**: Hostnames, internal IPs if printed
- **File contents**: If scripts output file contents

### 2. Runner Persistence
Self-hosted runners are persistent, unlike GitHub-hosted runners:
- Previous run artifacts might be accessible
- Environment variables persist between runs
- Installed software remains available
- Git credentials might be cached

## Mitigation Strategies

### 1. Use Secure Scripts
We provide `update-readme-memory-secure.py` which:
- Detects CI environment and suppresses sensitive output
- Hides email addresses and full commit hashes
- Limits file path disclosure
- Provides minimal progress indicators

### 2. Workflow Design
- **Minimal output**: Only print what's necessary
- **No debugging**: Remove verbose/debug flags
- **Sanitize paths**: Use relative paths, not absolute
- **Hide versions**: Don't print software versions
- **Generic errors**: Don't reveal system details in errors

### 3. Runner Configuration
```bash
# Use a dedicated user
sudo useradd -m -s /bin/bash github-runner

# Restricted permissions
chmod 700 /home/github-runner

# No sudo access
# Don't add to sudoers

# Isolated workspace
mkdir -p /home/github-runner/actions-runner/_work
```

### 4. Network Isolation
- Run on isolated network segment if possible
- Use firewall rules to limit outbound access
- No access to internal resources
- Consider using a dedicated VM/container

## What NOT to Do

❌ **Never** print environment variables
```bash
# BAD - reveals all env vars
env

# BAD - reveals specific vars
echo "HOME=$HOME"
```

❌ **Never** show system information
```bash
# BAD - reveals OS details
uname -a
cat /etc/os-release
```

❌ **Never** expose file structures
```bash
# BAD - reveals directory structure
find / -name "*.conf"
pwd
ls -la /home
```

❌ **Never** use verbose/debug modes
```bash
# BAD - too much output
set -x
python -v script.py
git clone --verbose
```

## Recommended Approach

For public repositories with self-hosted runners:

1. **Minimal workflows**: Only do what's absolutely necessary
2. **Separate private fork**: Consider using a private fork for sensitive operations
3. **GitHub-hosted fallback**: Use GitHub-hosted runners when possible
4. **Output validation**: Review all output before committing workflows
5. **Regular audits**: Check logs for accidental disclosures

## Alternative: Private Fork Strategy

1. Fork the public repo to a private repo
2. Run self-hosted runners on the private fork
3. Push changes back to public repo
4. Logs remain private

```bash
# Setup
git clone https://github.com/user/public-repo
cd public-repo
git remote add private https://github.com/user/private-fork
git push private main

# Workflow
git checkout -b feature
# ... make changes ...
git push private feature
# Run CI on private fork
git push origin feature
# Create PR on public repo
```

## Monitoring

Regularly check for information disclosure:
```bash
# Search logs for common leaks
# (Run on logs downloaded locally, not in CI!)
grep -i "home\|user\|password\|token\|key" workflow-logs.txt
grep -E "(/home/|/usr/|C:\\)" workflow-logs.txt
```

## Summary

- **Assume all output is public**
- **Design workflows for minimal disclosure**
- **Use secure scripts that detect CI environment**
- **Consider private fork for sensitive operations**
- **Regular security audits of logs**

The convenience of self-hosted runners comes with significant security responsibilities in public repositories.

Principle: systems-stewardship