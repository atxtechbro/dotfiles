"""
MLflow tracking implementation for automation procedures.

This module provides wrapper functions to track the execution of
close-issue and extract-best-frame procedures with full metrics,
parameters, and artifacts logging.
"""

import os
import time
import json
import subprocess
from datetime import datetime
from typing import Dict, Any, Optional, List
from pathlib import Path

import mlflow
from mlflow import log_metric, log_param, log_artifact, set_tag, log_text


def init_mlflow(tracking_uri: Optional[str] = None):
    """
    Initialize MLflow tracking configuration.

    Args:
        tracking_uri: Optional MLflow tracking server URI.
                     Defaults to local mlruns directory.
    """
    if tracking_uri is None:
        # Use the mlruns directory in the dotfiles root
        dotfiles_root = Path(__file__).parent.parent
        tracking_uri = f"file://{dotfiles_root}/mlruns"

    mlflow.set_tracking_uri(tracking_uri)
    mlflow.set_experiment("automation-procedures")


def log_procedure_start(procedure_name: str, params: Dict[str, Any]):
    """
    Log the start of a procedure execution.

    Args:
        procedure_name: Name of the procedure being executed
        params: Parameters passed to the procedure
    """
    log_param("procedure_name", procedure_name)
    log_param("start_time", datetime.now().isoformat())
    log_param("triggered_by", os.environ.get("USER", "unknown"))

    # Log all provided parameters
    for key, value in params.items():
        if value is not None:
            log_param(key, str(value)[:250])  # MLflow param limit is 250 chars


def log_procedure_end(success: bool, duration: float, error: Optional[str] = None):
    """
    Log the completion of a procedure execution.

    Args:
        success: Whether the procedure completed successfully
        duration: Execution time in seconds
        error: Optional error message if procedure failed
    """
    log_metric("success", 1 if success else 0)
    log_metric("duration_seconds", duration)
    log_param("end_time", datetime.now().isoformat())

    if error:
        log_text(error, "error.txt")
        set_tag("status", "failed")
    else:
        set_tag("status", "success")


def track_close_issue(issue_number: int,
                     repo: str = "atxtechbro/dotfiles",
                     additional_context: Optional[str] = None) -> Dict[str, Any]:
    """
    Track the execution of the close-issue procedure.

    Args:
        issue_number: GitHub issue number to close
        repo: Repository in owner/name format
        additional_context: Optional additional context for the procedure

    Returns:
        Dictionary containing execution results and metrics
    """
    init_mlflow()

    with mlflow.start_run(run_name=f"close_issue_{issue_number}"):
        start_time = time.time()
        result = {"success": False, "pr_url": None, "error": None}

        try:
            # Log initial parameters
            log_procedure_start("close-issue", {
                "issue_number": issue_number,
                "repository": repo,
                "additional_context": additional_context
            })

            # Step 1: Fetch issue details
            log_metric("step_1_fetch_issue", 1)
            issue_cmd = f"gh issue view {issue_number} --repo {repo} --json number,title,body,labels,state"
            issue_result = subprocess.run(issue_cmd, shell=True, capture_output=True, text=True)

            if issue_result.returncode == 0:
                issue_data = json.loads(issue_result.stdout)
                log_param("issue_title", issue_data.get("title", "")[:250])
                log_param("issue_state", issue_data.get("state", ""))

                if issue_data.get("labels"):
                    labels = ",".join([l.get("name", "") for l in issue_data["labels"]])
                    log_param("issue_labels", labels[:250])

            # Step 2: Create worktree
            log_metric("step_2_create_worktree", 1)
            worktree_name = f"1317-issue-{issue_number}"
            branch_name = f"fix-{issue_number}"

            # Check if worktree exists
            worktree_check = subprocess.run("git worktree list", shell=True, capture_output=True, text=True)
            if worktree_name not in worktree_check.stdout:
                worktree_cmd = f"git worktree add -b {branch_name} worktrees/{worktree_name} origin/main"
                subprocess.run(worktree_cmd, shell=True, check=True)
                log_param("worktree_path", f"worktrees/{worktree_name}")

            # Step 3: Track implementation metrics
            log_metric("step_3_implementation", 1)

            # In a real implementation, this would track actual file changes
            # For now, we'll log placeholder metrics
            log_metric("files_modified", 0)
            log_metric("lines_added", 0)
            log_metric("lines_removed", 0)

            # Step 4: Log completion
            duration = time.time() - start_time
            log_procedure_end(success=True, duration=duration)

            result["success"] = True
            set_tag("procedure", "close-issue")
            set_tag("repository", repo)

            # Log the result as artifact
            result_json = json.dumps(result, indent=2)
            log_text(result_json, "result.json")

        except Exception as e:
            duration = time.time() - start_time
            error_msg = f"Error in close-issue procedure: {str(e)}"
            log_procedure_end(success=False, duration=duration, error=error_msg)
            result["error"] = error_msg

        return result


def track_extract_best_frame(video_path: str,
                            output_dir: Optional[str] = None,
                            selection_criteria: Optional[str] = None) -> Dict[str, Any]:
    """
    Track the execution of the extract-best-frame procedure.

    Args:
        video_path: Path to the video file
        output_dir: Optional output directory for the best frame
        selection_criteria: Optional criteria for frame selection

    Returns:
        Dictionary containing execution results and metrics
    """
    init_mlflow()

    with mlflow.start_run(run_name=f"extract_best_frame_{Path(video_path).stem}"):
        start_time = time.time()
        result = {"success": False, "best_frame_path": None, "error": None}

        try:
            # Log initial parameters
            log_procedure_start("extract-best-frame", {
                "video_path": video_path,
                "output_dir": output_dir,
                "selection_criteria": selection_criteria
            })

            # Step 1: Validate video file
            log_metric("step_1_validate", 1)
            if os.path.exists(video_path):
                video_size = os.path.getsize(video_path) / (1024 * 1024)  # Size in MB
                log_metric("video_size_mb", video_size)
                log_param("video_name", Path(video_path).name)
            else:
                raise FileNotFoundError(f"Video file not found: {video_path}")

            # Step 2: Get video metadata
            log_metric("step_2_metadata", 1)
            ffprobe_cmd = f"ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 '{video_path}'"
            duration_result = subprocess.run(ffprobe_cmd, shell=True, capture_output=True, text=True)

            if duration_result.returncode == 0:
                try:
                    video_duration = float(duration_result.stdout.strip())
                    log_metric("video_duration_seconds", video_duration)
                except ValueError:
                    log_metric("video_duration_seconds", 0)

            # Step 3: Frame extraction (simulated)
            log_metric("step_3_extract_frames", 1)
            frames_dir = f"/tmp/frames_{Path(video_path).stem}"

            # In a real implementation, this would track actual frame extraction
            log_metric("frames_extracted", 0)
            log_metric("extraction_fps", 0.5)

            # Step 4: Frame selection (simulated)
            log_metric("step_4_selection", 1)
            log_metric("tournament_rounds", 0)

            # Step 5: Save best frame
            log_metric("step_5_save", 1)
            if output_dir:
                best_frame_path = f"{output_dir}/{Path(video_path).stem}_best_frame.jpg"
                log_param("best_frame_path", best_frame_path)
                result["best_frame_path"] = best_frame_path

            # Log completion
            duration = time.time() - start_time
            log_procedure_end(success=True, duration=duration)

            result["success"] = True
            set_tag("procedure", "extract-best-frame")
            set_tag("video_format", Path(video_path).suffix)

            # Log the result as artifact
            result_json = json.dumps(result, indent=2)
            log_text(result_json, "result.json")

        except Exception as e:
            duration = time.time() - start_time
            error_msg = f"Error in extract-best-frame procedure: {str(e)}"
            log_procedure_end(success=False, duration=duration, error=error_msg)
            result["error"] = error_msg

        return result


def query_runs(filter_string: Optional[str] = None,
               max_results: int = 100) -> List[Dict[str, Any]]:
    """
    Query MLflow runs with optional filtering.

    Args:
        filter_string: MLflow filter string (e.g., "metrics.duration_seconds > 60")
        max_results: Maximum number of results to return

    Returns:
        List of run dictionaries with metrics and parameters
    """
    init_mlflow()

    import pandas as pd

    runs = mlflow.search_runs(
        experiment_names=["automation-procedures"],
        filter_string=filter_string,
        max_results=max_results
    )

    if not runs.empty:
        return runs.to_dict('records')
    return []


def get_run_artifacts(run_id: str) -> List[str]:
    """
    Get list of artifacts for a specific run.

    Args:
        run_id: MLflow run ID

    Returns:
        List of artifact file paths
    """
    init_mlflow()

    client = mlflow.tracking.MlflowClient()
    artifacts = client.list_artifacts(run_id)

    return [artifact.path for artifact in artifacts]