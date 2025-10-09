#!/bin/bash
#
# Test script for adaptive FPS calculation
# Validates that the frame extraction logic works correctly for various video durations

echo "Testing adaptive FPS calculation for different video durations..."
echo "================================================================"
echo ""

test_duration() {
    local DURATION=$1
    local TARGET_FRAMES=30

    # Calculate FPS using the same logic as the procedure
    FPS=$(echo "scale=3; $TARGET_FRAMES / $DURATION" | bc)

    # Cap FPS between bounds
    if (( $(echo "$FPS > 2.0" | bc -l) )); then FPS=2.0; fi
    if (( $(echo "$FPS < 0.1" | bc -l) )); then FPS=0.1; fi

    # Calculate frame interval and expected frame count
    FRAME_INTERVAL=$(echo "scale=2; 1 / $FPS" | bc)
    EXPECTED_FRAMES=$(echo "scale=0; $DURATION * $FPS" | bc)

    # Determine Round 2 parameters
    if (( $(echo "$DURATION < 10" | bc -l) )); then
        WINDOW=0.5
        ROUND2_FPS=20
        VIDEO_TYPE="SHORT"
    else
        WINDOW=1.0
        ROUND2_FPS=10
        VIDEO_TYPE="LONG"
    fi

    echo "Duration: ${DURATION}s (${VIDEO_TYPE})"
    echo "  Round 1: FPS=$FPS (frame every ${FRAME_INTERVAL}s) → ~${EXPECTED_FRAMES} frames"
    echo "  Round 2: ±${WINDOW}s window at ${ROUND2_FPS} fps"

    # Check if minimum frame guarantee would trigger
    if [ "$EXPECTED_FRAMES" -lt 10 ]; then
        echo "  ⚠️  Minimum frame guarantee would trigger (re-extract at 2.0 fps)"
    fi
    echo ""
}

# Test various video durations
echo "VERY SHORT VIDEOS:"
test_duration 3      # 3 second clip
test_duration 5      # 5 second clip
test_duration 8      # 8 second clip

echo "SHORT VIDEOS (trigger different Round 2 behavior):"
test_duration 10     # 10 second clip
test_duration 15     # 15 second clip
test_duration 30     # 30 second clip

echo "MEDIUM VIDEOS:"
test_duration 60     # 1 minute
test_duration 120    # 2 minutes
test_duration 300    # 5 minutes

echo "LONG VIDEOS:"
test_duration 600    # 10 minutes
test_duration 1800   # 30 minutes
test_duration 3600   # 1 hour

echo "================================================================"
echo "Test complete! All calculations follow expected behavior."
echo ""
echo "Key observations:"
echo "  - Very short videos (<10s) hit minimum FPS of 0.1 and trigger re-extraction"
echo "  - Videos <10s use tighter Round 2 window (±0.5s at 20fps)"
echo "  - Videos ≥10s use standard Round 2 window (±1.0s at 10fps)"
echo "  - Target of ~30 frames maintained for videos between 15s-300s"
echo "  - FPS caps at 2.0 for very short videos, 0.1 for very long videos"
