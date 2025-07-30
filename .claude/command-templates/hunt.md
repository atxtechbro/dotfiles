# Hunt for LinkedIn Jobs

Discover jobs on LinkedIn and prepare them for the /apply command pipeline.

## Usage
- `/hunt` - Full job discovery across all configured queries
- `/hunt test` - Quick test with only 2 queries

## What This Does
1. Opens browser with LinkedIn
2. Guides you through login (first time only)
3. Searches for AI orchestrator and engineering manager roles
4. Saves discovered jobs to JSON
5. Shows you ready-to-run /apply commands

## The Pipeline
```
/hunt → discovers jobs → shows /apply commands → you pick which to apply to
```

## Execute Job Discovery

```bash
#!/bin/bash
set -euo pipefail

# Navigate to the automation directory
cd "$(dirname "${BASH_SOURCE[0]}")/../../../lifehacking/career/linkedin/automation" || {
    echo "❌ Could not find LinkedIn automation directory"
    echo "   Expected: lifehacking/career/linkedin/automation"
    exit 1
}

# Check if this is a test run
if [[ "${1:-}" == "test" ]]; then
    echo "🧪 Running in test mode (2 queries only)..."
    if [[ -x "./test-job-hunter.js" ]]; then
        node ./test-job-hunter.js
    else
        echo "❌ Test script not found. Using safe mode instead..."
        node ./job-hunter-safe.js
    fi
else
    echo "🎯 LinkedIn Job Hunter"
    echo "━━━━━━━━━━━━━━━━━━━━"
    
    # Use safe mode for better error handling
    if [[ -x "./job-hunter-safe.js" ]]; then
        node ./job-hunter-safe.js
    else
        # Fallback to main script
        node ./linkedin-job-hunter.js
    fi
fi

# Show discovered jobs with /apply commands
echo ""
echo "📋 Jobs Ready for Application:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get today's date
DATE=$(date +%Y-%m-%d)
JOB_FILE="../../job-leads/${DATE}-jobs.json"

if [[ -f "$JOB_FILE" ]]; then
    # Show each job with its /apply command
    jq -r '.[] | "
💼 \(.title) at \(.company)
📍 \(.location)
🔗 \(.url | split("/") | last)

/apply \"\(.url)\"
"' "$JOB_FILE"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Total jobs discovered: $(jq length "$JOB_FILE")"
    echo ""
    echo "💡 Copy any /apply command above to create a tailored resume"
else
    echo "❌ No jobs found. The job hunter may have encountered an error."
fi
```

## Troubleshooting

**First time setup:**
- When the browser opens, login to LinkedIn manually
- Your session will be saved for future runs

**"No jobs found" error:**
- Check if node_modules exists: `npm install`
- Check if Playwright is installed: `npx playwright install chromium`
- Try test mode first: `/hunt test`

**Session expired:**
- Delete saved session: `rm -rf ~/.playwright-linkedin-profile/`
- Run `/hunt` again and login fresh

## Principle
This command embodies "subtraction creates value" - one command instead of multiple scripts.