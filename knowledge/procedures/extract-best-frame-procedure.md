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
