---
description: Extract the most flattering frame from a video selfie using Claude's visual judgment
argument-hint: <video-path>
---

## Setup
!VIDEO_PATH="$1"
!VIDEO_NAME="$(basename "$VIDEO_PATH" .mp4)"
!OUTPUT_DIR="$(dirname "$VIDEO_PATH")/extracted-frames"
!FRAMES_DIR="$OUTPUT_DIR/${VIDEO_NAME}_frames"
!mkdir -p "$FRAMES_DIR"

# Extract Best Frame from Video Using Claude's Visual Judgment

{{ INJECT:procedures/extract-best-frame-procedure.md }}