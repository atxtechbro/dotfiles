#!/usr/bin/env python3
"""
Test script to demonstrate MLflow tracking functionality.

This script shows how the MLflow wrappers track procedure execution
with metrics, parameters, and artifacts.
"""

import sys
import os
from pathlib import Path

# Add parent directory to path to import tracking module
sys.path.insert(0, str(Path(__file__).parent.parent))

from tracking import track_close_issue, track_extract_best_frame, init_mlflow
from tracking.mlflow_tracker import query_runs


def main():
    """Run test demonstrations of MLflow tracking."""

    print("=" * 60)
    print("MLflow Tracking Integration Test")
    print("=" * 60)

    # Initialize MLflow with local tracking
    init_mlflow()
    print("\n✓ MLflow initialized with local tracking")
    print("  View UI at: http://localhost:5000")

    # Test 1: Track a close-issue procedure (simulated)
    print("\n1. Testing close-issue tracking...")
    print("-" * 40)

    result = track_close_issue(
        issue_number=1317,
        repo="atxtechbro/dotfiles",
        additional_context="Testing MLflow integration"
    )

    if result["success"]:
        print("✓ Successfully tracked close-issue procedure")
        print(f"  - Issue: #1317")
        print(f"  - Success: {result['success']}")
    else:
        print(f"✗ Error: {result['error']}")

    # Test 2: Track an extract-best-frame procedure (simulated)
    print("\n2. Testing extract-best-frame tracking...")
    print("-" * 40)

    # Use a test video path (doesn't need to exist for this demo)
    test_video = "/tmp/test_video.mp4"

    result = track_extract_best_frame(
        video_path=test_video,
        output_dir="/tmp",
        selection_criteria="best smile"
    )

    # Handle the expected FileNotFoundError gracefully for demo
    if not result["success"]:
        print(f"✓ Successfully tracked extract-best-frame procedure (with expected error)")
        print(f"  - Video: {test_video}")
        print(f"  - Note: {result['error']}")
    else:
        print(f"✓ Successfully tracked extract-best-frame procedure")
        print(f"  - Video: {test_video}")
        print(f"  - Success: {result['success']}")

    # Test 3: Query recent runs
    print("\n3. Querying recent MLflow runs...")
    print("-" * 40)

    recent_runs = query_runs(max_results=5)
    print(f"✓ Found {len(recent_runs)} recent runs")

    for i, run in enumerate(recent_runs[:3], 1):
        print(f"\n  Run {i}:")
        print(f"    - Procedure: {run.get('params.procedure_name', 'N/A')}")
        print(f"    - Duration: {run.get('metrics.duration_seconds', 'N/A'):.2f}s")
        print(f"    - Success: {run.get('metrics.success', 'N/A')}")
        print(f"    - Status: {run.get('tags.status', 'N/A')}")

    print("\n" + "=" * 60)
    print("MLflow Integration Test Complete!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. View runs in MLflow UI: http://localhost:5000")
    print("2. Click on a run to see detailed metrics and artifacts")
    print("3. Use the search bar to filter runs (e.g., 'metrics.success = 1')")
    print("4. Compare multiple runs to analyze trends")


if __name__ == "__main__":
    main()