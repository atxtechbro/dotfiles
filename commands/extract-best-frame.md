---
description: Extract best frame from video using AI
---

# Extract Best Frame Procedure
#
# This procedure extracts frames from a video and uses the agent's visual judgment
# to select the best frame through a tournament-style comparison.
#
# CONFIGURABLE SELECTION CRITERIA (Config in Environment Principle):
# - Reads user preferences from .agent-config.yml
# - Selection criteria: "flattering", "professional", "expressive", "candid", "energetic"
# - Target person description (for multi-person videos)
# - Customizable selection factors (expression, lighting, composition, etc.)
# - See: knowledge/principles/config-in-environment.md
#
# ADAPTIVE BEHAVIOR:
# - Round 1: Dynamically adjusts FPS based on video duration (targets 20-50 frames)
#   - FPS bounded between 0.1-2.0 fps to avoid extremes
#   - Minimum 10 frames guaranteed even for very short videos
# - Round 2: Adapts window size based on video length
#   - Videos <10s: ±0.5s window at 20 fps for tight precision
#   - Videos ≥10s: ±1.0s window at 10 fps for standard refinement
#
# BATCH PROCESSING:
# - Supports single or multiple videos (newline-separated paths)
# - Processes videos sequentially (one after another)
# - Creates unique output directories per video
# - TODO: Future enhancement for concurrent processing (videos are independent)
#
# DRY-RUN MODE:
# - Preview execution plan without running commands
# - Shows resolved config, planned steps, would-be bash commands
# - Supports both human-readable and machine-readable (--json) output
# - Usage: "extract-best-frame video.mp4 --dry-run" or "extract-best-frame video.mp4 --dry-run --json"

## Invocation
- Primary command: "extract-best-frame <video_path(s)> [<frames_dir>] [<output_dir>]"
- Alternative formats: "best-frame <video_path(s)>"
- Single video: "extract-best-frame /path/to/video.mp4"
- Multiple videos (newline-separated):
  ```
  extract-best-frame /path/to/video1.mp4
  /path/to/video2.mp4
  /path/to/video3.mp4
  ```
- Optional modifiers:
  - `--dry-run`: Preview execution plan without running commands (shows config, planned steps, would-be commands)
  - `--json`: Output in machine-readable JSON format (useful with --dry-run for tooling)
- Parsing rules:
  - Detect flags anywhere in user input after command name
  - Flags can be combined: "extract-best-frame video.mp4 --dry-run --json"
  - Natural language variants accepted: "dry run", "preview", "show me what would happen"
- Optional selection criteria: Any trailing text after the arguments should be treated as guidance (preferences, qualities to optimize for) and incorporated with graceful flexibility.

Examples:
- "extract-best-frame video.mp4" → Normal execution
- "extract-best-frame video.mp4 --dry-run" → Preview without execution
- "extract-best-frame video.mp4 --dry-run --json" → Machine-readable preview
- "extract-best-frame video.mp4 dry run" → Natural language variant

## Step 0: Load User Configuration

Load selection preferences from .agent-config.yml (Config in Environment principle):

!# YAML config parser with nested key support
!CONFIG_FILE="${DOTFILES_ROOT:-.}/.agent-config.yml"
!
!# Function to extract nested YAML values
!# Supports paths like: "agents.extract-best-frame.selection_criteria.optimize_for"
!get_config() {
!  local path="$1"
!  local default="$2"
!
!  if [ ! -f "$CONFIG_FILE" ]; then
!    echo "$default"
!    return
!  fi
!
!  # Try Python with PyYAML for robust parsing (handles nested keys)
!  if command -v python3 &>/dev/null; then
!    python3 -c "
!import sys
!try:
!    import yaml
!    with open('$CONFIG_FILE') as f:
!        config = yaml.safe_load(f) or {}
!
!    # Navigate nested path
!    value = config
!    for key in '$path'.split('.'):
!        if isinstance(value, dict) and key in value:
!            value = value[key]
!        else:
!            print('$default')
!            sys.exit(0)
!
!    # Variable substitution
!    if isinstance(value, str):
!        import os
!        result = value.replace('\${HOME}', os.path.expanduser('~'))
!        # Substitute user.* references
!        if '\${user.' in result:
!            user = config.get('user', {})
!            result = result.replace('\${user.github_username}', user.get('github_username', ''))
!            result = result.replace('\${user.name}', user.get('name', ''))
!            persona_desc = user.get('persona', {}).get('description', '')
!            result = result.replace('\${user.persona.description}', persona_desc)
!        print(result)
!    else:
!        print(value)
!except ImportError:
!    # PyYAML not available, use fallback
!    sys.exit(1)
!except Exception:
!    print('$default')
!" 2>/dev/null && return
!  fi
!
!  # Fallback: simple grep for top-level keys only
!  local simple_key="${path##*.}"  # Get last component
!  grep "^[[:space:]]*${simple_key}:" "$CONFIG_FILE" 2>/dev/null | \
!    sed 's/.*:[[:space:]]*//' | \
!    tr -d '"' || echo "$default"
!}
!
!# Load configuration with graceful defaults
!CONFIG_OPTIMIZE_FOR=$(get_config "agents.extract-best-frame.selection_criteria.optimize_for" "flattering")
!CONFIG_TARGET_PERSON=$(get_config "agents.extract-best-frame.selection_criteria.target_person" "the person in the video")
!
!echo "📋 Configuration loaded:"
!echo "  Selection criteria: $CONFIG_OPTIMIZE_FOR"
!echo "  Target person: $CONFIG_TARGET_PERSON"
!echo ""

If .agent-config.yml doesn't exist or PyYAML unavailable, gracefully falls back to defaults.

## Step 0b: Parse Execution Modifiers

Detect dry-run and JSON output flags from user input:

!# Parse flags from the user's command invocation
!# Supports --dry-run, --json, and natural language variants
!DRY_RUN=false
!JSON_OUTPUT=false
!
!# Get the full user input (this variable is provided by the LLM context)
!USER_INPUT="${USER_INPUT:-$*}"
!
!# Check for dry-run flag variants
if echo "$USER_INPUT" | grep -qiE '(--dry-run|dry[[:space:]]+run|preview|show[[:space:]]+me[[:space:]]+what[[:space:]]+would[[:space:]]+happen)'; then
!  DRY_RUN=true
!fi
!
!# Check for JSON output flag
!if echo "$USER_INPUT" | grep -qiE '(--json)'; then
!  JSON_OUTPUT=true
!fi
!
!# If dry-run mode detected, show banner
!if [ "$DRY_RUN" = "true" ]; then
!  if [ "$JSON_OUTPUT" = "true" ]; then
!    echo '{"dry_run": true, "mode": "json"}'
!  else
!    echo "🧠 Dry Run Mode: Extract Best Frame"
!    echo "──────────────────────────────────────"
!    echo "Preview mode enabled - no commands will be executed"
!    echo ""
!  fi
!fi

The dry-run mode will:
- Show all resolved configuration values
- Display planned execution steps with calculations
- Preview would-be bash commands without executing them
- Output either human-readable format (default) or JSON (with --json flag)

## Step 1: Parse and Initialize Batch Processing

Parse video paths (supports single or multiple newline-separated videos):
!# Read all video paths into an array
!mapfile -t VIDEO_PATHS < <(echo "$VIDEO_INPUT" | grep -v '^$' | grep '\.mp4$\|\.mov$\|\.avi$\|\.mkv$')
!TOTAL_VIDEOS=${#VIDEO_PATHS[@]}
!echo "Found $TOTAL_VIDEOS video(s) to process"

Initialize batch tracking:
!declare -a BATCH_RESULTS
!CURRENT_VIDEO=0

## Step 1b: Dry-Run Mode Output (If Enabled)

If dry-run mode is active, show the execution plan instead of running commands:

!if [ "$DRY_RUN" = "true" ]; then
!  # For each video, show what would happen
!  for VIDEO_PATH in "${VIDEO_PATHS[@]}"; do
!    CURRENT_VIDEO=$((CURRENT_VIDEO + 1))
!
!    # Get video metadata (safe to run in dry-run - read-only operation)
!    if [ -f "$VIDEO_PATH" ]; then
!      DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_PATH" 2>/dev/null || echo "unknown")
!    else
!      DURATION="video not found"
!    fi
!
!    VIDEO_NAME=$(basename "$VIDEO_PATH" | sed 's/\.[^.]*$//')
!
!    # Calculate planned values
!    TARGET_FRAMES=30
!    if [ "$DURATION" != "unknown" ] && [ "$DURATION" != "video not found" ]; then
!      FPS=$(echo "scale=3; $TARGET_FRAMES / $DURATION" | bc)
!      if (( $(echo "$FPS > 2.0" | bc -l) )); then FPS=2.0; fi
!      if (( $(echo "$FPS < 0.1" | bc -l) )); then FPS=0.1; fi
!      FRAME_INTERVAL=$(echo "scale=2; 1 / $FPS" | bc)
!
!      # Round 2 parameters
!      if (( $(echo "$DURATION < 10" | bc -l) )); then
!        WINDOW=0.5
!        ROUND2_FPS=20
!      else
!        WINDOW=1.0
!        ROUND2_FPS=10
!      fi
!    else
!      FPS="N/A"
!      FRAME_INTERVAL="N/A"
!      WINDOW="N/A"
!      ROUND2_FPS="N/A"
!    fi
!
    # Define directory paths (should match the main execution logic)
    FRAMES_DIR="${FRAMES_DIR:-/tmp/extract-best-frame/frames}"
    OUTPUT_DIR="${OUTPUT_DIR:-/tmp/extract-best-frame/output}"
    
    VIDEO_FRAMES_DIR="${FRAMES_DIR}/${VIDEO_NAME}"
    VIDEO_OUTPUT_DIR="${OUTPUT_DIR}/${VIDEO_NAME}"
!
!    # Output based on mode
!    if [ "$JSON_OUTPUT" = "true" ]; then
!      # JSON format output
!      cat <<EOF
!{
!  "dry_run": true,
!  "command": "extract-best-frame",
!  "video_index": $CURRENT_VIDEO,
!  "total_videos": $TOTAL_VIDEOS,
!  "input": {
!    "video_path": "$VIDEO_PATH",
!    "video_exists": $([ -f "$VIDEO_PATH" ] && echo "true" || echo "false"),
!    "video_duration": "$DURATION",
!    "frames_dir": "$VIDEO_FRAMES_DIR",
!    "output_dir": "$VIDEO_OUTPUT_DIR"
!  },
!  "config": {
!    "optimize_for": "$CONFIG_OPTIMIZE_FOR",
!    "target_person": "$CONFIG_TARGET_PERSON"
!  },
!  "planned_execution": {
!    "round1": {
!      "target_frames": $TARGET_FRAMES,
!      "fps": "$FPS",
!      "frame_interval": "$FRAME_INTERVAL",
!      "command": "ffmpeg -i \"$VIDEO_PATH\" -vf \"fps=$FPS\" -q:v 2 \"$VIDEO_FRAMES_DIR/frame_%04d.jpg\" -loglevel error"
!    },
!    "round2": {
!      "window_seconds": "$WINDOW",
!      "fps": "$ROUND2_FPS",
      "command": "ffmpeg -ss <WINNER_TIME-$WINDOW> -i \\"$VIDEO_PATH\\" -t <DURATION_R2> -vf \\"fps=$ROUND2_FPS\\" -q:v 2 \\"$VIDEO_FRAMES_DIR/round2/refined_%03d.jpg\\" -loglevel error"
!    },
!    "final_output": {
!      "path": "$VIDEO_OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg",
!      "command": "cp \"<BEST_FRAME>\" \"$VIDEO_OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg\""
!    }
!  },
!  "execution_status": "skipped (dry-run mode)"
!}
!EOF
!    else
!      # Human-readable format
!      echo ""
!      echo "Video $CURRENT_VIDEO of $TOTAL_VIDEOS: $VIDEO_NAME"
!      echo "──────────────────────────────────────"
!      echo "Input Video: $VIDEO_PATH"
!      [ -f "$VIDEO_PATH" ] && echo "Status: ✓ Found" || echo "Status: ✗ Not found"
!      echo "Duration: ${DURATION}s"
!      echo ""
!      echo "Resolved Configuration:"
!      echo "  optimize_for: $CONFIG_OPTIMIZE_FOR"
!      echo "  target_person: $CONFIG_TARGET_PERSON"
!      echo "  frames_dir: $VIDEO_FRAMES_DIR"
!      echo "  output_dir: $VIDEO_OUTPUT_DIR"
!      echo ""
!      echo "Planned Execution Steps:"
!      echo "  1. Calculate adaptive FPS: $TARGET_FRAMES frames / ${DURATION}s = $FPS fps"
!      echo "  2. Extract ~$TARGET_FRAMES frames (1 frame every ${FRAME_INTERVAL}s)"
!      echo "  3. Run tournament selection (Round 1) - AI compares frames"
!      echo "  4. Extract refined frames around winner (±${WINDOW}s at ${ROUND2_FPS} fps)"
!      echo "  5. Select best frame from Round 2 - AI finds perfect moment"
!      echo "  6. Copy to: $VIDEO_OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg"
!      echo ""
!      echo "Would Execute Commands:"
!      echo "  \$ mkdir -p \"$VIDEO_FRAMES_DIR\" \"$VIDEO_OUTPUT_DIR\""
!      echo "  \$ ffmpeg -i \"$VIDEO_PATH\" -vf \"fps=$FPS\" -q:v 2 \"$VIDEO_FRAMES_DIR/frame_%04d.jpg\" -loglevel error"
      echo "  \\$ ffmpeg -ss <WINNER_TIME-$WINDOW> -i \\"$VIDEO_PATH\\" -t <DURATION_R2> -vf \\"fps=$ROUND2_FPS\\" -q:v 2 \\"$VIDEO_FRAMES_DIR/round2/refined_%03d.jpg\\" -loglevel error"
!      echo "  \$ cp \"<BEST_FRAME>\" \"$VIDEO_OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg\""
!      echo ""
!    fi
!  done
!
!  # Exit after dry-run preview
!  if [ "$JSON_OUTPUT" != "true" ]; then
!    echo "──────────────────────────────────────"
!    echo "(No actions executed - dry-run mode)"
!    echo ""
!    echo "To execute for real, run without --dry-run flag"
!  fi
!  exit 0
!fi

## Step 1c: Batch Processing Loop

For each video, process sequentially:
!for VIDEO_PATH in "${VIDEO_PATHS[@]}"; do
!  CURRENT_VIDEO=$((CURRENT_VIDEO + 1))
!  echo ""
!  echo "=========================================="
!  echo "Processing video $CURRENT_VIDEO of $TOTAL_VIDEOS"
!  echo "=========================================="
!  echo "Video: $VIDEO_PATH"

Validate video file exists:
!  if [ ! -f "$VIDEO_PATH" ]; then
!    echo "Error: Video file not found: $VIDEO_PATH"
!    BATCH_RESULTS+=("FAILED: $VIDEO_PATH (file not found)")
!    continue
!  fi

Extract video filename for unique output naming:
!  VIDEO_NAME=$(basename "$VIDEO_PATH" | sed 's/\.[^.]*$//')
!  VIDEO_FRAMES_DIR="${FRAMES_DIR}/${VIDEO_NAME}"
!  VIDEO_OUTPUT_DIR="${OUTPUT_DIR}/${VIDEO_NAME}"
!  mkdir -p "$VIDEO_FRAMES_DIR" "$VIDEO_OUTPUT_DIR"
!  echo "Output will be saved to: $VIDEO_OUTPUT_DIR"

## Step 2: Extract Frames (Adaptive)

Get video duration to calculate optimal frame extraction rate:
!  DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_PATH")
!  echo "Video duration: ${DURATION}s"

Calculate adaptive FPS targeting 20-50 frames for Round 1:
!  TARGET_FRAMES=30
!  FPS=$(echo "scale=3; $TARGET_FRAMES / $DURATION" | bc)

Cap FPS between reasonable bounds (0.1 to 2.0 fps):
!  if (( $(echo "$FPS > 2.0" | bc -l) )); then FPS=2.0; fi
!  if (( $(echo "$FPS < 0.1" | bc -l) )); then FPS=0.1; fi
!  FRAME_INTERVAL=$(echo "scale=2; 1 / $FPS" | bc)
!  echo "Using adaptive FPS: $FPS (1 frame every ${FRAME_INTERVAL}s)"

Extract frames at adaptive intervals:
!  ffmpeg -i "$VIDEO_PATH" -vf "fps=$FPS" -q:v 2 "$VIDEO_FRAMES_DIR/frame_%04d.jpg" -loglevel error

Count the extracted frames:
!  FRAME_COUNT=$(ls -1 "$VIDEO_FRAMES_DIR"/frame_*.jpg 2>/dev/null | wc -l)
!  echo "Extracted $FRAME_COUNT frames from video"

Ensure minimum frame coverage for very short videos:
!  MIN_FRAMES=10
!  if [ "$FRAME_COUNT" -lt "$MIN_FRAMES" ]; then
!    echo "Warning: Only $FRAME_COUNT frames extracted. Re-extracting with higher FPS for better coverage..."
!    ffmpeg -i "$VIDEO_PATH" -vf "fps=2.0" -q:v 2 "$VIDEO_FRAMES_DIR/frame_%04d.jpg" -loglevel error -y
!    FRAME_COUNT=$(ls -1 "$VIDEO_FRAMES_DIR"/frame_*.jpg 2>/dev/null | wc -l)
!    echo "Re-extracted $FRAME_COUNT frames for analysis"
!  fi

## Step 3: Tournament Selection Using Claude

Now I'll help you find the best frame using a tournament-style selection process optimized for **${CONFIG_OPTIMIZE_FOR}** criteria.

First, let me see all the extracted frames to understand what we're working with:

!  ls -1 "$VIDEO_FRAMES_DIR"/frame_*.jpg | head -20

I'll now conduct a tournament where I compare pairs of frames to find the best match for your preferences.

### Round 1: Initial Pairs

Let me start by comparing frames in pairs. For each pair, I'll select the frame that best matches **${CONFIG_OPTIMIZE_FOR}** criteria.

**Selection Criteria (from config):**
- **Optimize for:** ${CONFIG_OPTIMIZE_FOR}
- **Target person:** ${CONFIG_TARGET_PERSON}

**Evaluation factors:**
- Facial expression (appropriate for ${CONFIG_OPTIMIZE_FOR} style)
- Eye engagement and gaze direction
- Overall pose and composition
- Image clarity and lighting
- Context and background

!  echo "Starting tournament selection with '${CONFIG_OPTIMIZE_FOR}' criteria..."
!  echo "Looking for: ${CONFIG_TARGET_PERSON}"

## Step 4: Claude's Visual Comparison

I'll now examine the frames and select the best one optimized for **${CONFIG_OPTIMIZE_FOR}** style. Let me look at a sample of frames first to get a sense of the video:

[Claude will use the Read tool to view frames and make comparisons based on user's configured criteria]

The selection process:
1. I'll compare frames in pairs based on ${CONFIG_OPTIMIZE_FOR} criteria
2. Winners advance to the next round
3. Continue until one frame remains
4. That frame is saved as the best match for ${CONFIG_OPTIMIZE_FOR} + ${CONFIG_TARGET_PERSON}

## Step 4b: Round 2 - Fine-Grained Selection (Adaptive)

After identifying the best frame from Round 1, perform fine-grained refinement:

Calculate the timestamp of the Round 1 winner and extract refined frames:
!  WINNER_NUMBER=$(echo "$BEST_FRAME" | grep -o '[0-9]\+')
!  WINNER_TIME=$(echo "scale=2; $WINNER_NUMBER * $FRAME_INTERVAL" | bc)
!  echo "Round 1 winner is at approximately ${WINNER_TIME}s in the video"

Determine adaptive Round 2 parameters based on video duration:
!  if (( $(echo "$DURATION < 10" | bc -l) )); then
!    # Short videos: tighter window, higher precision
!    WINDOW=0.5
!    ROUND2_FPS=20
!    echo "Short video detected: Using ±${WINDOW}s window with ${ROUND2_FPS} fps"
!  else
!    # Longer videos: standard window
!    WINDOW=1.0
!    ROUND2_FPS=10
!    echo "Using standard ±${WINDOW}s window with ${ROUND2_FPS} fps"
!  fi

Calculate Round 2 extraction window:
!  START_TIME=$(echo "scale=2; if ($WINNER_TIME - $WINDOW < 0) 0 else $WINNER_TIME - $WINDOW" | bc)
!  DURATION_R2=$(echo "scale=2; $WINDOW * 2" | bc)
!  mkdir -p "$VIDEO_FRAMES_DIR/round2"

Extract refined frames around the winner:
!  ffmpeg -ss $START_TIME -i "$VIDEO_PATH" -t $DURATION_R2 -vf "fps=$ROUND2_FPS" -q:v 2 "$VIDEO_FRAMES_DIR/round2/refined_%03d.jpg" -loglevel error
!  echo "Extracted $(ls -1 "$VIDEO_FRAMES_DIR"/round2/*.jpg 2>/dev/null | wc -l) refined frames for Round 2"

[Claude will compare the refined frames to find the absolute best moment for **${CONFIG_OPTIMIZE_FOR}** style, capturing micro-expressions and perfect timing]

The refined selection captures moments that match **${CONFIG_OPTIMIZE_FOR}** criteria:
- Peak expressions appropriate for the style (e.g., genuine smile for "flattering", neutral for "professional")
- Optimal body positioning and posture
- Perfect contextual elements (environment, lighting, composition)
- Target person characteristics: ${CONFIG_TARGET_PERSON}

!  echo "Round 2 complete: Found best '${CONFIG_OPTIMIZE_FOR}' frame with sub-second precision"

## Step 5: Save the Best Frame

After the selection process, the winning frame will be copied to the output directory:
!  BEST_FRAME_OUTPUT="$VIDEO_OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg"
!  cp "$VIDEO_FRAMES_DIR/$BEST_FRAME" "$BEST_FRAME_OUTPUT"
!  echo "✓ Best frame saved to: $BEST_FRAME_OUTPUT"

Track result for batch summary:
!  BATCH_RESULTS+=("SUCCESS: $VIDEO_NAME → $BEST_FRAME_OUTPUT")

## Step 6: Cleanup (Per Video)

Keep frames for review (remove manually if not needed):
!  echo "Frames kept in $VIDEO_FRAMES_DIR for review"

Close the batch processing loop:
!done

## Step 7: Batch Summary

Display summary of all processed videos:
!echo ""
!echo "=========================================="
!echo "BATCH PROCESSING COMPLETE"
!echo "=========================================="
!echo "Processed $TOTAL_VIDEOS video(s)"
!echo ""
!echo "Results:"
!for result in "${BATCH_RESULTS[@]}"; do
!  echo "  $result"
!done
!echo ""

## Next Steps

The best frame extraction is complete!

**For single video:**
- View the best frame at: `$OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg`
- Review all extracted frames in: `$FRAMES_DIR/${VIDEO_NAME}`

**For batch processing:**
- All best frames saved to their respective output directories
- Check the batch summary above for individual file paths
- Review frames for each video in: `$FRAMES_DIR/<video_name>/`

**Future Improvements:**
- Concurrent processing: Since videos are independent, they could be processed in parallel for significant speed improvements (currently sequential)
