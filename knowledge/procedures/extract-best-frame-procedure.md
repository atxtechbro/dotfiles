# Extract Best Frame Procedure
#
# This procedure extracts frames from a video and uses the agent's visual judgment
# to select the most flattering frame through a tournament-style comparison.

## Invocation
- Primary command: "extract-best-frame <video_path> [<frames_dir>] [<output_dir>]"
- Alternative formats: "best-frame <video_path>"
- Optional selection criteria: Any trailing text after the arguments should be treated as guidance (preferences, qualities to optimize for) and incorporated with graceful flexibility.

## Step 1: Validate Input

Ensure the video file exists:
!test -f "$VIDEO_PATH" || { echo "Error: Video file not found: $VIDEO_PATH"; exit 1; }

## Step 2: Extract Frames

Extract frames at regular intervals (every 2 seconds):
!ffmpeg -i "$VIDEO_PATH" -vf "fps=0.5" -q:v 2 "$FRAMES_DIR/frame_%04d.jpg" -loglevel error

Count the extracted frames:
!FRAME_COUNT=$(ls -1 "$FRAMES_DIR"/frame_*.jpg 2>/dev/null | wc -l)
!echo "Extracted $FRAME_COUNT frames from video"

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

## Step 4b: Round 2 - Fine-Grained Selection

After identifying the best frame from Round 1, perform fine-grained refinement:

Calculate the timestamp of the Round 1 winner and extract refined frames:
!WINNER_NUMBER=$(echo "$BEST_FRAME" | grep -o '[0-9]\+')
!WINNER_TIME=$((WINNER_NUMBER * 2))  # Since we extracted at 0.5 fps (every 2 seconds)
!START_TIME=$((WINNER_TIME - 1))
!mkdir -p "$FRAMES_DIR/round2"

Extract 20 frames at 0.1-second intervals around the winner (±1 second window):
!ffmpeg -ss $START_TIME -i "$VIDEO_PATH" -t 2 -vf "fps=10" -q:v 2 "$FRAMES_DIR/round2/refined_%03d.jpg" -loglevel error
!echo "Extracted $(ls -1 "$FRAMES_DIR"/round2/*.jpg | wc -l) refined frames for Round 2"

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
