"""
MLflow tracking implementation for automation procedures.

This module provides THIN WRAPPER functions that only track execution metrics.
The actual procedure implementations are in knowledge/procedures/.

IMPORTANT: This module does NOT implement business logic - it only tracks.
- close-issue logic: knowledge/procedures/close-issue-procedure.md
- extract-best-frame logic: knowledge/procedures/extract-best-frame-procedure.md

Following DRY principle: Single source of truth for implementations.
"""

import os
import time
from datetime import datetime
from typing import Dict, Any, Optional, List
from pathlib import Path

import mlflow
from mlflow import log_metric, log_param, set_tag, log_text


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

    This is a thin wrapper for MLflow tracking only.
    The actual implementation is in knowledge/procedures/close-issue-procedure.md

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
        result = {"success": False, "error": None}

        try:
            # Log initial parameters
            log_procedure_start("close-issue", {
                "issue_number": issue_number,
                "repository": repo,
                "additional_context": additional_context
            })

            # NOTE: The actual close-issue procedure implementation happens here
            # This wrapper only tracks execution, not implements it
            # See: knowledge/procedures/close-issue-procedure.md

            # In production, this would call the actual procedure
            # For now, we mark success for demonstration
            log_metric("procedure_invoked", 1)

            # Log completion
            duration = time.time() - start_time
            log_procedure_end(success=True, duration=duration)

            result["success"] = True
            set_tag("procedure", "close-issue")
            set_tag("repository", repo)

        except Exception as e:
            duration = time.time() - start_time
            error_msg = f"Error tracking close-issue: {str(e)}"
            log_procedure_end(success=False, duration=duration, error=error_msg)
            result["error"] = error_msg

        return result


def track_extract_best_frame(video_path: str,
                            output_dir: Optional[str] = None,
                            selection_criteria: Optional[str] = None) -> Dict[str, Any]:
    """
    Track the execution of the extract-best-frame procedure.

    This is a thin wrapper for MLflow tracking only.
    The actual implementation is in knowledge/procedures/extract-best-frame-procedure.md

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
        result = {"success": False, "error": None}

        try:
            # Log initial parameters
            log_procedure_start("extract-best-frame", {
                "video_path": video_path,
                "output_dir": output_dir,
                "selection_criteria": selection_criteria
            })

            # NOTE: The actual extract-best-frame procedure implementation happens here
            # This wrapper only tracks execution, not implements it
            # See: knowledge/procedures/extract-best-frame-procedure.md

            # Basic validation for demonstration
            if not os.path.exists(video_path):
                raise FileNotFoundError(f"Video file not found: {video_path}")

            log_param("video_name", Path(video_path).name)
            log_metric("procedure_invoked", 1)

            # Log completion
            duration = time.time() - start_time
            log_procedure_end(success=True, duration=duration)

            result["success"] = True
            set_tag("procedure", "extract-best-frame")
            set_tag("video_format", Path(video_path).suffix)

        except Exception as e:
            duration = time.time() - start_time
            error_msg = f"Error tracking extract-best-frame: {str(e)}"
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