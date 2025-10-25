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

## Procedure

See knowledge/procedures/extract-best-clips-procedure.md for the complete implementation.

The procedure follows these high-level steps:

1. **Load Configuration** - Read user preferences from .agent-config.yml
2. **Parse Execution Modifiers** - Detect --dry-run, --json, --count flags
3. **Scene Detection** - Use ffmpeg to detect scene boundaries
4. **Extract Representative Frames** - Get middle frame from each scene
5. **AI Scene Ranking** - Analyze and rank scenes based on criteria
6. **Extract Top Clips** - Extract top N scenes as video clips
7. **Output & Summary** - Save clips and metadata, show batch results

## Configuration

Configuration is read from `.agent-config.yml`:

```yaml
agents:
  extract-best-clips:
    selection_criteria:
      optimize_for: "interesting"  # interesting, action, dialogue, highlights, story
      factors:
        - "visual_interest"
        - "composition"
        - "action_level"
        - "scene_duration"

    scene_detection:
      threshold: 0.3  # 0.1-0.5, higher = fewer scenes
      min_duration: 2.0  # seconds
      max_duration: 30.0  # seconds

    output:
      clips_dir: "/tmp/extract-best-clips/clips"
      metadata_dir: "/tmp/extract-best-clips/metadata"
      default_count: 1  # number of clips to extract
```

## Next Steps

After extracting clips:
- View clips in: `<output_dir>/<video_name>/clip_001.mp4`, `clip_002.mp4`, etc.
- Review metadata: `<output_dir>/<video_name>/metadata.json` (timestamps, rankings, scene info)
- Adjust config in `.agent-config.yml` to tune scene detection or selection criteria
