"""
MLflow tracking integration for automation procedures.

Provides wrappers to track execution metrics, parameters, and artifacts
for close-issue and extract-best-frame procedures.
"""

from .mlflow_tracker import (
    track_close_issue,
    track_extract_best_frame,
    init_mlflow,
    log_procedure_start,
    log_procedure_end,
)

__all__ = [
    "track_close_issue",
    "track_extract_best_frame",
    "init_mlflow",
    "log_procedure_start",
    "log_procedure_end",
]