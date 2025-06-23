#!/bin/bash
# Test fitness workflow with act for PR #32
# Principle: tracer-bullets

set -euo pipefail

echo "Testing fitness workflow with new prompt orchestrator..."

# Ensure we're in lifehacking directory
LIFEHACKING_DIR="$HOME/ppv/pillars/lifehacking"
if [ ! -d "$LIFEHACKING_DIR" ]; then
    echo "Error: Lifehacking directory not found at $LIFEHACKING_DIR"
    exit 1
fi

# Check out the feature branch from PR #32
echo "Checking out feature branch from PR #32..."
cd "$LIFEHACKING_DIR"
git fetch origin

# Find the correct remote branch
REMOTE_BRANCH=$(git branch -r | grep -E "origin/.*prompt.*orchestrator" | head -1 | xargs)
if [ -n "$REMOTE_BRANCH" ]; then
    echo "Found remote branch: $REMOTE_BRANCH"
    LOCAL_BRANCH=$(echo "$REMOTE_BRANCH" | sed 's|origin/||')
    git checkout -B "$LOCAL_BRANCH" "$REMOTE_BRANCH"
else
    echo "No prompt orchestrator branch found, using current branch"
fi

# Create test data
echo "Setting up test data..."
mkdir -p "$LIFEHACKING_DIR/test_pictures"

# Create dummy test images (act won't have real images)
touch "$LIFEHACKING_DIR/test_pictures/PXL_20250623_120000.jpg"
touch "$LIFEHACKING_DIR/test_pictures/PXL_20250623_120100.jpg"
touch "$LIFEHACKING_DIR/test_pictures/PXL_20250623_120200.jpg"

# Create test MACROS.json if needed
if [ ! -f "$LIFEHACKING_DIR/fitness/MACROS.json" ]; then
    echo '{
  "calories": 2800,
  "protein": 200,
  "carbs": 350,
  "fat": 78
}' > "$LIFEHACKING_DIR/fitness/MACROS.json"
fi

# Run act with workflow inputs
echo "Running act to test generate_analysis workflow..."
cd "$LIFEHACKING_DIR"

# Use act to run the workflow with inputs
# Note: We'll use dummy values since act won't have real secrets
act workflow_dispatch \
    -W .github/workflows/generate_analysis.yml \
    -s OPENAI_API_KEY="dummy-key-for-testing" \
    -s PAT_GITHUB="dummy-pat-for-testing" \
    --input prompt_path="fitness/prompts/assessment_prompt.md" \
    --input picture_path="test_pictures" \
    --input output_path="fitness/SCORECARD.md" \
    --input inject_context="true" \
    --input docker_rename="false" \
    --dryrun

echo "Act dry run complete. To run the actual workflow:"
echo "1. Remove --dryrun flag"
echo "2. Provide real API keys"
echo "3. Use real picture files"

# Cleanup
rm -rf "$LIFEHACKING_DIR/test_pictures"

echo "Test complete!"