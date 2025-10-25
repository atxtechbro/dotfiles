---
description: Extract best clips from video using AI
---

# Extract Best Clips Procedure
#
# This procedure detects scenes in a video and uses the agent's visual judgment
# to select the best clip(s) based on configurable criteria.
#
# CONFIGURABLE SELECTION CRITERIA (Config in Environment Principle):
# - Reads user preferences from .agent-config.yml
# - Selection criteria: "interesting", "action", "dialogue", "highlights", "story"
# - Scene detection threshold (sensitivity for detecting scene changes)
# - Clip duration constraints (min/max clip length)
# - Customizable selection factors (visual interest, composition, action, etc.)
# - See: knowledge/principles/config-in-environment.md
#
# ADAPTIVE BEHAVIOR:
# - Scene Detection: Dynamically detects scenes using ffmpeg scenecut filter
#   - Configurable threshold (0.1-0.5) for scene change sensitivity
#   - Filters scenes by duration (min/max constraints)
# - Clip Selection: AI evaluates each scene's representative frame + metadata
#   - Ranks scenes based on configured criteria
#   - Extracts top N clips (default: 1, configurable)
#
# BATCH PROCESSING:
# - Supports single or multiple videos (newline-separated paths)
# - Processes videos sequentially (one after another)
# - Creates unique output directories per video
# - TODO: Future enhancement for concurrent processing (videos are independent)
#
# DRY-RUN MODE:
# - Preview execution plan without running commands
# - Shows resolved config, scene detection plan, would-be bash commands
# - Supports both human-readable and machine-readable (--json) output
# - Usage: "extract-best-clips video.mp4 --dry-run" or "extract-best-clips video.mp4 --dry-run --json"
# - Pattern documentation: knowledge/procedures/dry-run-pattern.md

## Invocation
- Primary command: "extract-best-clips <video_path(s)> [--count N] [--clips-dir <dir>] [--output-dir <dir>]"
- Alternative formats: "best-clips <video_path(s)>"
- Single video: "extract-best-clips /path/to/video.mp4"
- Multiple videos (newline-separated):
  ```
  extract-best-clips /path/to/video1.mp4
  /path/to/video2.mp4
  /path/to/video3.mp4
  ```
- Optional modifiers:
  - `--count N`: Number of clips to extract (default: 1)
  - `--dry-run`: Preview execution plan without running commands
  - `--json`: Output in machine-readable JSON format (useful with --dry-run)
  - `--threshold X`: Scene detection threshold 0.1-0.5 (default: from config or 0.3)
- Parsing rules:
  - Detect flags anywhere in user input after command name
  - Flags can be combined: "extract-best-clips video.mp4 --count 3 --dry-run"
  - Natural language variants accepted: "dry run", "preview", "show me what would happen"
- Optional selection criteria: Any trailing text after arguments should be treated as guidance

Examples:
- "extract-best-clips video.mp4" → Extract 1 best clip
- "extract-best-clips video.mp4 --count 5" → Extract 5 best clips
- "extract-best-clips video.mp4 --dry-run" → Preview without execution
- "extract-best-clips video.mp4 --count 3 --dry-run --json" → Machine-readable preview

## Step 0: Load User Configuration

Load selection preferences from .agent-config.yml (Config in Environment principle):

!# YAML config parser with nested key support
!CONFIG_FILE="${DOTFILES_ROOT:-.}/.agent-config.yml"
!
!# Function to extract nested YAML values
!# Supports paths like: "agents.extract-best-clips.selection_criteria.optimize_for"
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
!CONFIG_OPTIMIZE_FOR=$(get_config "agents.extract-best-clips.selection_criteria.optimize_for" "interesting")
!CONFIG_SCENE_THRESHOLD=$(get_config "agents.extract-best-clips.scene_detection.threshold" "0.3")
!CONFIG_MIN_DURATION=$(get_config "agents.extract-best-clips.scene_detection.min_duration" "2.0")
!CONFIG_MAX_DURATION=$(get_config "agents.extract-best-clips.scene_detection.max_duration" "30.0")
!CONFIG_DEFAULT_COUNT=$(get_config "agents.extract-best-clips.output.default_count" "1")
!CONFIG_CLIPS_DIR=$(get_config "agents.extract-best-clips.output.clips_dir" "/tmp/extract-best-clips/clips")
!CONFIG_METADATA_DIR=$(get_config "agents.extract-best-clips.output.metadata_dir" "/tmp/extract-best-clips/metadata")
!
!echo "📋 Configuration loaded:"
!echo "  Selection criteria: $CONFIG_OPTIMIZE_FOR"
!echo "  Scene threshold: $CONFIG_SCENE_THRESHOLD (0.1=sensitive, 0.5=strict)"
!echo "  Clip duration: ${CONFIG_MIN_DURATION}s - ${CONFIG_MAX_DURATION}s"
!echo "  Default clip count: $CONFIG_DEFAULT_COUNT"
!echo ""

If .agent-config.yml doesn't exist or PyYAML unavailable, gracefully falls back to defaults.

## Step 0b: Parse Execution Modifiers

Detect dry-run, JSON output, and count flags from user input:

!# Parse flags from the user's command invocation
!# Supports --dry-run, --json, --count N, --threshold X
!DRY_RUN=false
!JSON_OUTPUT=false
!CLIP_COUNT=$CONFIG_DEFAULT_COUNT
!SCENE_THRESHOLD=$CONFIG_SCENE_THRESHOLD
!
!# Get the full user input (this variable is provided by the LLM context)
!USER_INPUT="${USER_INPUT:-$*}"
!
!# Check for dry-run flag variants
!if echo "$USER_INPUT" | grep -qiE '(--dry-run|dry[[:space:]]+run|preview|show[[:space:]]+me[[:space:]]+what[[:space:]]+would[[:space:]]+happen)'; then
!  DRY_RUN=true
!fi
!
!# Check for JSON output flag
!if echo "$USER_INPUT" | grep -qiE '(--json)'; then
!  JSON_OUTPUT=true
!fi
!
!# Parse --count flag
!if echo "$USER_INPUT" | grep -qE '\--count[[:space:]]+[0-9]+'; then
!  CLIP_COUNT=$(echo "$USER_INPUT" | grep -oE '\--count[[:space:]]+[0-9]+' | grep -oE '[0-9]+')
!fi
!
!# Parse --threshold flag
!if echo "$USER_INPUT" | grep -qE '\--threshold[[:space:]]+[0-9.]+'; then
!  SCENE_THRESHOLD=$(echo "$USER_INPUT" | grep -oE '\--threshold[[:space:]]+[0-9.]+' | grep -oE '[0-9.]+')
!fi
!
!# If dry-run mode detected, show banner
!if [ "$DRY_RUN" = "true" ]; then
!  if [ "$JSON_OUTPUT" = "true" ]; then
!    echo '{"dry_run": true, "mode": "json"}'
!  else
!    echo "🧠 Dry Run Mode: Extract Best Clips"
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
!    # Define directory paths
!    VIDEO_CLIPS_DIR="${CONFIG_CLIPS_DIR}/${VIDEO_NAME}"
!    VIDEO_METADATA_DIR="${CONFIG_METADATA_DIR}/${VIDEO_NAME}"
!
!    # Output based on mode
!    if [ "$JSON_OUTPUT" = "true" ]; then
!      # JSON format output
!      cat <<EOF
!{
!  "dry_run": true,
!  "command": "extract-best-clips",
!  "video_index": $CURRENT_VIDEO,
!  "total_videos": $TOTAL_VIDEOS,
!  "input": {
!    "video_path": "$VIDEO_PATH",
!    "video_exists": $([ -f "$VIDEO_PATH" ] && echo "true" || echo "false"),
!    "video_duration": "$DURATION",
!    "clips_dir": "$VIDEO_CLIPS_DIR",
!    "metadata_dir": "$VIDEO_METADATA_DIR"
!  },
!  "config": {
!    "optimize_for": "$CONFIG_OPTIMIZE_FOR",
!    "scene_threshold": "$SCENE_THRESHOLD",
!    "min_duration": "$CONFIG_MIN_DURATION",
!    "max_duration": "$CONFIG_MAX_DURATION",
!    "clip_count": $CLIP_COUNT
!  },
!  "planned_execution": {
!    "scene_detection": {
!      "method": "ffmpeg scenecut filter",
!      "threshold": "$SCENE_THRESHOLD",
!      "command": "ffmpeg -i \"$VIDEO_PATH\" -filter:v \"select='gt(scene,$SCENE_THRESHOLD)',showinfo\" -f null - 2>&1 | grep 'pts_time'"
!    },
!    "frame_extraction": {
!      "description": "Extract middle frame from each scene",
!      "command": "ffmpeg -ss <SCENE_MID_TIME> -i \"$VIDEO_PATH\" -vframes 1 \"$VIDEO_CLIPS_DIR/scene_<N>_frame.jpg\""
!    },
!    "clip_extraction": {
!      "description": "Extract top $CLIP_COUNT clip(s)",
!      "command": "ffmpeg -ss <START_TIME> -i \"$VIDEO_PATH\" -t <DURATION> -c copy \"$VIDEO_CLIPS_DIR/clip_<N>.mp4\""
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
!      echo "  scene_threshold: $SCENE_THRESHOLD (lower=more scenes)"
!      echo "  min_duration: ${CONFIG_MIN_DURATION}s"
!      echo "  max_duration: ${CONFIG_MAX_DURATION}s"
!      echo "  clip_count: $CLIP_COUNT"
!      echo "  clips_dir: $VIDEO_CLIPS_DIR"
!      echo "  metadata_dir: $VIDEO_METADATA_DIR"
!      echo ""
!      echo "Planned Execution Steps:"
!      echo "  1. Detect scenes using ffmpeg scenecut (threshold=$SCENE_THRESHOLD)"
!      echo "  2. Filter scenes by duration (${CONFIG_MIN_DURATION}s - ${CONFIG_MAX_DURATION}s)"
!      echo "  3. Extract representative frame from each scene"
!      echo "  4. AI analyzes frames and ranks scenes based on '$CONFIG_OPTIMIZE_FOR' criteria"
!      echo "  5. Extract top $CLIP_COUNT clip(s) from video"
!      echo "  6. Save clips to: $VIDEO_CLIPS_DIR/"
!      echo "  7. Generate metadata: $VIDEO_METADATA_DIR/metadata.json"
!      echo ""
!      echo "Would Execute Commands:"
!      echo "  \$ mkdir -p \"$VIDEO_CLIPS_DIR\" \"$VIDEO_METADATA_DIR\""
!      echo "  \$ ffmpeg -i \"$VIDEO_PATH\" -filter:v \"select='gt(scene,$SCENE_THRESHOLD)',showinfo\" -f null - 2>&1 | grep 'pts_time'"
!      echo "  \$ # For each scene: ffmpeg -ss <MID_TIME> -i \"$VIDEO_PATH\" -vframes 1 \"scene_N_frame.jpg\""
!      echo "  \$ # For top clips: ffmpeg -ss <START> -i \"$VIDEO_PATH\" -t <DUR> -c copy \"clip_N.mp4\""
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
!  VIDEO_CLIPS_DIR="${CONFIG_CLIPS_DIR}/${VIDEO_NAME}"
!  VIDEO_METADATA_DIR="${CONFIG_METADATA_DIR}/${VIDEO_NAME}"
!  mkdir -p "$VIDEO_CLIPS_DIR" "$VIDEO_METADATA_DIR"
!  echo "Output will be saved to: $VIDEO_CLIPS_DIR"

## Step 2: Scene Detection

Get video duration:
!  DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_PATH")
!  echo "Video duration: ${DURATION}s"

Detect scenes using ffmpeg scenecut filter:
!  echo "Detecting scenes with threshold $SCENE_THRESHOLD..."
!  SCENE_TIMES=$(ffmpeg -i "$VIDEO_PATH" -filter:v "select='gt(scene,$SCENE_THRESHOLD)',showinfo" -f null - 2>&1 | \
!    grep 'pts_time' | \
!    sed -n 's/.*pts_time:\([0-9.]*\).*/\1/p')
!
!  # Convert to array and add start/end markers
!  mapfile -t SCENE_TIMESTAMPS < <(echo "$SCENE_TIMES")
!  # Prepend 0.0 (video start) if not present
!  if [ ${#SCENE_TIMESTAMPS[@]} -eq 0 ] || [ "$(echo "${SCENE_TIMESTAMPS[0]} > 1.0" | bc)" -eq 1 ]; then
!    SCENE_TIMESTAMPS=("0.0" "${SCENE_TIMESTAMPS[@]}")
!  fi
!  # Append video end
!  SCENE_TIMESTAMPS+=("$DURATION")
!
!  SCENE_COUNT=$((${#SCENE_TIMESTAMPS[@]} - 1))
!  echo "Detected $SCENE_COUNT scenes"

Build scene metadata (start, end, duration):
!  declare -a SCENE_STARTS
!  declare -a SCENE_ENDS
!  declare -a SCENE_DURATIONS
!  declare -a VALID_SCENES
!
!  for ((i=0; i<SCENE_COUNT; i++)); do
!    START=${SCENE_TIMESTAMPS[$i]}
!    END=${SCENE_TIMESTAMPS[$((i+1))]}
!    # Calculate duration (use bc if available, otherwise awk)
!    if command -v bc >/dev/null 2>&1; then
!      DUR=$(echo "$END - $START" | bc)
!    else
!      DUR=$(awk "BEGIN {printf \"%.2f\", $END - $START}")
!    fi
!
!    # Filter by duration constraints
!    VALID=false
!    if command -v bc >/dev/null 2>&1; then
!      if (( $(echo "$DUR >= $CONFIG_MIN_DURATION" | bc -l) )) && (( $(echo "$DUR <= $CONFIG_MAX_DURATION" | bc -l) )); then
!        VALID=true
!      fi
!    else
!      # Fallback: awk comparison
!      if [ "$(awk "BEGIN {print ($DUR >= $CONFIG_MIN_DURATION && $DUR <= $CONFIG_MAX_DURATION)}")" = "1" ]; then
!        VALID=true
!      fi
!    fi
!
!    if [ "$VALID" = "true" ]; then
!      SCENE_STARTS+=("$START")
!      SCENE_ENDS+=("$END")
!      SCENE_DURATIONS+=("$DUR")
!      VALID_SCENES+=("$i")
!    fi
!  done
!
!  VALID_SCENE_COUNT=${#VALID_SCENES[@]}
!  echo "Found $VALID_SCENE_COUNT valid scenes (${CONFIG_MIN_DURATION}s - ${CONFIG_MAX_DURATION}s)"

If no valid scenes found:
!  if [ "$VALID_SCENE_COUNT" -eq 0 ]; then
!    echo "Warning: No valid scenes found. Adjusting constraints or threshold may help."
!    BATCH_RESULTS+=("FAILED: $VIDEO_NAME (no valid scenes)")
!    continue
!  fi

## Step 3: Extract Representative Frames

Extract middle frame from each valid scene:
!  echo "Extracting representative frames from $VALID_SCENE_COUNT scenes..."
!  for ((i=0; i<VALID_SCENE_COUNT; i++)); do
!    SCENE_NUM=${VALID_SCENES[$i]}
!    START=${SCENE_STARTS[$i]}
!    END=${SCENE_ENDS[$i]}
!
!    # Calculate middle timestamp
!    if command -v bc >/dev/null 2>&1; then
!      MID_TIME=$(echo "scale=2; ($START + $END) / 2" | bc)
!    else
!      MID_TIME=$(awk "BEGIN {printf \"%.2f\", ($START + $END) / 2}")
!    fi
!
!    # Extract frame at middle of scene
!    FRAME_PATH="$VIDEO_CLIPS_DIR/scene_$(printf '%03d' $SCENE_NUM)_frame.jpg"
!    ffmpeg -ss "$MID_TIME" -i "$VIDEO_PATH" -vframes 1 -q:v 2 "$FRAME_PATH" -loglevel error
!
!    echo "  Scene $SCENE_NUM: ${START}s - ${END}s (${SCENE_DURATIONS[$i]}s) → frame extracted"
!  done
!
!  echo "Extracted $VALID_SCENE_COUNT representative frames"

## Step 4: AI Scene Ranking

Now I'll help you find the best clip(s) using AI-powered scene analysis optimized for **${CONFIG_OPTIMIZE_FOR}** criteria.

Let me examine all the scene frames to understand the video content:

!  echo "Starting AI scene analysis with '${CONFIG_OPTIMIZE_FOR}' criteria..."
!  echo "Target clips: $CLIP_COUNT"

[Claude will use the Read tool to view scene frames and analyze each scene based on configured criteria]

**Selection Criteria (from config):**
- **Optimize for:** ${CONFIG_OPTIMIZE_FOR}
- **Clip count:** ${CLIP_COUNT}

**Evaluation factors:**
- Visual interest and composition
- Action level and dynamics
- Scene clarity and lighting
- Content relevance to ${CONFIG_OPTIMIZE_FOR}
- Scene duration (${CONFIG_MIN_DURATION}s - ${CONFIG_MAX_DURATION}s)

The AI ranking process:
1. Analyze each scene's representative frame
2. Consider scene duration and position in video
3. Rank scenes based on ${CONFIG_OPTIMIZE_FOR} criteria
4. Select top ${CLIP_COUNT} clip(s)

After AI analysis, the ranked scene indices are stored:
!  # Example: RANKED_SCENES=(5 12 3 8 1) - scene indices sorted by ranking
!  # This will be determined by Claude's analysis

## Step 5: Extract Top Clips

Extract the top ${CLIP_COUNT} scene(s) as video clips:
!  echo ""
!  echo "Extracting top $CLIP_COUNT clip(s)..."
!  declare -a EXTRACTED_CLIPS
!
!  for ((clip_idx=0; clip_idx<CLIP_COUNT && clip_idx<VALID_SCENE_COUNT; clip_idx++)); do
!    # Get the scene index for this ranked position
!    SCENE_IDX=${RANKED_SCENES[$clip_idx]}
!
!    # Get scene timing
!    START=${SCENE_STARTS[$SCENE_IDX]}
!    DUR=${SCENE_DURATIONS[$SCENE_IDX]}
!
!    # Extract clip using copy codec (fast, lossless)
!    CLIP_NUM=$(printf '%03d' $((clip_idx + 1)))
!    CLIP_PATH="$VIDEO_CLIPS_DIR/${VIDEO_NAME}_clip_${CLIP_NUM}.mp4"
!
!    ffmpeg -ss "$START" -i "$VIDEO_PATH" -t "$DUR" -c copy "$CLIP_PATH" -loglevel error
!
!    echo "  Clip $CLIP_NUM: ${START}s (${DUR}s) → $CLIP_PATH"
!    EXTRACTED_CLIPS+=("$CLIP_PATH")
!  done
!
!  echo "✓ Extracted $CLIP_COUNT clip(s)"

## Step 6: Generate Metadata

Create metadata file with scene rankings and clip information:
!  METADATA_FILE="$VIDEO_METADATA_DIR/metadata.json"
!  cat > "$METADATA_FILE" <<EOF
!{
!  "video": {
!    "path": "$VIDEO_PATH",
!    "name": "$VIDEO_NAME",
!    "duration": $DURATION
!  },
!  "config": {
!    "optimize_for": "$CONFIG_OPTIMIZE_FOR",
!    "scene_threshold": $SCENE_THRESHOLD,
!    "min_duration": $CONFIG_MIN_DURATION,
!    "max_duration": $CONFIG_MAX_DURATION,
!    "clip_count": $CLIP_COUNT
!  },
!  "scenes": {
!    "total_detected": $SCENE_COUNT,
!    "valid_count": $VALID_SCENE_COUNT,
!    "extracted_clips": $CLIP_COUNT
!  },
!  "clips": [
!EOF
!
!  for ((clip_idx=0; clip_idx<CLIP_COUNT && clip_idx<VALID_SCENE_COUNT; clip_idx++)); do
!    SCENE_IDX=${RANKED_SCENES[$clip_idx]}
!    START=${SCENE_STARTS[$SCENE_IDX]}
!    DUR=${SCENE_DURATIONS[$SCENE_IDX]}
!    CLIP_NUM=$(printf '%03d' $((clip_idx + 1)))
!
!    # Add comma if not first entry
!    [ $clip_idx -gt 0 ] && echo "    ," >> "$METADATA_FILE"
!
!    cat >> "$METADATA_FILE" <<CLIP_EOF
!    {
!      "clip_number": $((clip_idx + 1)),
!      "scene_index": $SCENE_IDX,
!      "rank": $((clip_idx + 1)),
!      "start_time": $START,
!      "duration": $DUR,
!      "file": "${VIDEO_NAME}_clip_${CLIP_NUM}.mp4"
!    }
!CLIP_EOF
!  done
!
!  cat >> "$METADATA_FILE" <<EOF
!
!  ]
!}
!EOF
!
!  echo "✓ Metadata saved to: $METADATA_FILE"

Track result for batch summary:
!  BATCH_RESULTS+=("SUCCESS: $VIDEO_NAME → $CLIP_COUNT clip(s) in $VIDEO_CLIPS_DIR")

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

The best clip extraction is complete!

**For single video:**
- View clips in: `$VIDEO_CLIPS_DIR/<video_name>_clip_001.mp4`, `clip_002.mp4`, etc.
- Review metadata: `$VIDEO_METADATA_DIR/metadata.json` (timestamps, rankings, scene info)
- Review scene frames: `$VIDEO_CLIPS_DIR/scene_NNN_frame.jpg`

**For batch processing:**
- All clips saved to their respective output directories
- Check the batch summary above for individual paths
- Review metadata for each video in: `$CONFIG_METADATA_DIR/<video_name>/`

**Tuning the extraction:**
- Adjust `scene_threshold` in config (or --threshold flag): lower = more scenes, higher = fewer scenes
- Modify `optimize_for` criteria to change selection focus
- Change `min_duration` / `max_duration` to adjust clip length constraints
- Increase `--count` to extract more clips

**Future Improvements:**
- Concurrent processing: Since videos are independent, they could be processed in parallel for significant speed improvements (currently sequential)
- Audio analysis: Incorporate audio features (volume, speech, music) into scene ranking
- Motion detection: Use motion vectors to identify action-heavy scenes
- Face detection: Prioritize scenes with faces or specific people
