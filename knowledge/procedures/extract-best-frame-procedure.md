# Extract Best Frame Procedure
#
# This procedure extracts frames from a video and uses the agent's visual judgment
# to select the most flattering frame through a tournament-style comparison.
#
# ADAPTIVE BEHAVIOR:
# - Round 1: Dynamically adjusts FPS based on video duration (targets 20-50 frames)
#   - FPS bounded between 0.1-2.0 fps to avoid extremes
#   - Minimum 10 frames guaranteed even for very short videos
# - Round 2: Adapts window size based on video length
#   - Videos <10s: ±0.5s window at 20 fps for tight precision
#   - Videos ≥10s: ±1.0s window at 10 fps for standard refinement

## Invocation
- Primary command: "extract-best-frame <video_path> [<frames_dir>] [<output_dir>]"
- Alternative formats: "best-frame <video_path>"
- Optional selection criteria: Any trailing text after the arguments should be treated as guidance (preferences, qualities to optimize for) and incorporated with graceful flexibility.

## Step 1: Validate Input

Ensure the video file exists:
!test -f "$VIDEO_PATH" || { echo "Error: Video file not found: $VIDEO_PATH"; exit 1; }

## Step 2: Extract Frames (Adaptive)

Get video duration to calculate optimal frame extraction rate:
!DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_PATH")
!echo "Video duration: ${DURATION}s"

Calculate adaptive FPS targeting 20-50 frames for Round 1:
!TARGET_FRAMES=30
!FPS=$(echo "scale=3; $TARGET_FRAMES / $DURATION" | bc)

Cap FPS between reasonable bounds (0.1 to 2.0 fps):
!if (( $(echo "$FPS > 2.0" | bc -l) )); then FPS=2.0; fi
!if (( $(echo "$FPS < 0.1" | bc -l) )); then FPS=0.1; fi
!FRAME_INTERVAL=$(echo "scale=2; 1 / $FPS" | bc)
!echo "Using adaptive FPS: $FPS (1 frame every ${FRAME_INTERVAL}s)"

Extract frames at adaptive intervals:
!ffmpeg -i "$VIDEO_PATH" -vf "fps=$FPS" -q:v 2 "$FRAMES_DIR/frame_%04d.jpg" -loglevel error

Count the extracted frames:
!FRAME_COUNT=$(ls -1 "$FRAMES_DIR"/frame_*.jpg 2>/dev/null | wc -l)
!echo "Extracted $FRAME_COUNT frames from video"

Ensure minimum frame coverage for very short videos:
!MIN_FRAMES=10
!if [ "$FRAME_COUNT" -lt "$MIN_FRAMES" ]; then
!  echo "Warning: Only $FRAME_COUNT frames extracted. Re-extracting with higher FPS for better coverage..."
!  ffmpeg -i "$VIDEO_PATH" -vf "fps=2.0" -q:v 2 "$FRAMES_DIR/frame_%04d.jpg" -loglevel error -y
!  FRAME_COUNT=$(ls -1 "$FRAMES_DIR"/frame_*.jpg 2>/dev/null | wc -l)
!  echo "Re-extracted $FRAME_COUNT frames for analysis"
!fi

## Step 3: Tournament Selection Using Claude

Now I'll help you find the best selfie frame using a tournament-style selection process.

First, let me see all the extracted frames to understand what we're working with:

!ls -1 "$FRAMES_DIR"/frame_*.jpg | head -20

I'll now conduct a tournament where I compare pairs of frames to find the most flattering selfie.

### Round 1: Initial Pairs

Let me start by comparing frames in pairs. For each pair, I'll select the more flattering selfie based on:
- Facial expression and smile
- Eye openness and engagement
- Overall pose and composition
- Image clarity and lighting

!echo "Starting tournament selection..."

## Step 4: Claude's Visual Comparison

I'll now examine the frames and select the best one. Let me look at a sample of frames first to get a sense of the video:

[Claude will use the Read tool to view frames and make comparisons]

The selection process:
1. I'll compare frames in pairs
2. Winners advance to the next round
3. Continue until one frame remains
4. That frame is saved as the best selfie

## Step 4b: Round 2 - Fine-Grained Selection (Adaptive)

After identifying the best frame from Round 1, perform fine-grained refinement:

Calculate the timestamp of the Round 1 winner and extract refined frames:
!WINNER_NUMBER=$(echo "$BEST_FRAME" | grep -o '[0-9]\+')
!WINNER_TIME=$(echo "scale=2; $WINNER_NUMBER * $FRAME_INTERVAL" | bc)
!echo "Round 1 winner is at approximately ${WINNER_TIME}s in the video"

Determine adaptive Round 2 parameters based on video duration:
!if (( $(echo "$DURATION < 10" | bc -l) )); then
!  # Short videos: tighter window, higher precision
!  WINDOW=0.5
!  ROUND2_FPS=20
!  echo "Short video detected: Using ±${WINDOW}s window with ${ROUND2_FPS} fps"
!else
!  # Longer videos: standard window
!  WINDOW=1.0
!  ROUND2_FPS=10
!  echo "Using standard ±${WINDOW}s window with ${ROUND2_FPS} fps"
!fi

Calculate Round 2 extraction window:
!START_TIME=$(echo "scale=2; if ($WINNER_TIME - $WINDOW < 0) 0 else $WINNER_TIME - $WINDOW" | bc)
!DURATION_R2=$(echo "scale=2; $WINDOW * 2" | bc)
!mkdir -p "$FRAMES_DIR/round2"

Extract refined frames around the winner:
!ffmpeg -ss $START_TIME -i "$VIDEO_PATH" -t $DURATION_R2 -vf "fps=$ROUND2_FPS" -q:v 2 "$FRAMES_DIR/round2/refined_%03d.jpg" -loglevel error
!echo "Extracted $(ls -1 "$FRAMES_DIR"/round2/*.jpg 2>/dev/null | wc -l) refined frames for Round 2"

[Claude will compare the refined frames to find the absolute best moment, capturing micro-expressions and perfect timing]

The refined selection captures:
- Peak facial expressions and smiles
- Optimal muscle definition moments
- Perfect food/cooking action shots
- Ideal environmental atmosphere

!echo "Round 2 complete: Found best frame with sub-second precision"

## Step 5: Save the Best Frame

After the selection process, the winning frame will be copied to the output directory:
!cp "$FRAMES_DIR/$BEST_FRAME" "$OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg"
!echo "Best frame saved to: $OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg"

## Step 6: Cleanup

Remove temporary frames directory (optional):
!echo "Keeping frames in $FRAMES_DIR for review. Remove manually if not needed."

{{ INJECT:principles/tracer-bullets.md }}

## Next Steps

The best selfie frame has been extracted! You can:
1. View it at: `$OUTPUT_DIR/${VIDEO_NAME}_best_frame.jpg`
2. Review all frames in: `$FRAMES_DIR`
3. Run again with different videos
