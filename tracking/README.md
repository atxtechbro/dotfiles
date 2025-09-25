# MLflow Tracking Integration

This module provides MLflow tracking capabilities for our automation procedures, enabling reproducibility, observability, and debugging of all automated actions.

## Features

- **Full Metrics Tracking**: Execution time, success rates, step completion
- **Parameter Logging**: Issue numbers, file paths, context
- **Artifact Storage**: Code changes, PR descriptions, extracted frames
- **Searchable History**: Query and filter past executions
- **Visual Dashboard**: MLflow UI for exploring runs

## Installation

MLflow is installed globally via uv:

```bash
uv tool install mlflow
```

## Usage

### Starting MLflow UI

The MLflow tracking UI provides a web interface to view all tracked runs:

```bash
# Start MLflow UI (runs on http://localhost:5000)
mlflow ui --backend-store-uri ~/ppv/pillars/dotfiles/mlruns
```

### Tracking Procedures

The tracking module provides wrapper functions for our automation procedures:

```python
from tracking import track_close_issue, track_extract_best_frame

# Track close-issue execution
result = track_close_issue(
    issue_number=123,
    repo="atxtechbro/dotfiles",
    additional_context="Fix bug in authentication"
)

# Track extract-best-frame execution
result = track_extract_best_frame(
    video_path="/path/to/video.mp4",
    output_dir="/path/to/output",
    selection_criteria="best smile"
)
```

### Querying Runs

Find specific runs using MLflow's query capabilities:

```python
from tracking.mlflow_tracker import query_runs

# Find slow executions
slow_runs = query_runs(
    filter_string="metrics.duration_seconds > 60"
)

# Find failed runs
failed_runs = query_runs(
    filter_string="metrics.success = 0"
)

# Find runs for specific issue
issue_runs = query_runs(
    filter_string="params.issue_number = '123'"
)
```

## Tracked Metrics

### close-issue Procedure

**Parameters:**
- `issue_number`: GitHub issue number
- `repository`: Target repository
- `issue_title`: Issue title
- `issue_labels`: Comma-separated labels
- `worktree_path`: Git worktree location

**Metrics:**
- `step_1_fetch_issue`: Issue fetch completion
- `step_2_create_worktree`: Worktree creation
- `step_3_implementation`: Implementation completion
- `files_modified`: Number of files changed
- `lines_added`: Lines added
- `lines_removed`: Lines removed
- `duration_seconds`: Total execution time
- `success`: Success indicator (1 or 0)

### extract-best-frame Procedure

**Parameters:**
- `video_path`: Input video file path
- `video_name`: Video filename
- `output_dir`: Output directory
- `selection_criteria`: Frame selection criteria
- `best_frame_path`: Path to selected frame

**Metrics:**
- `video_size_mb`: Video file size
- `video_duration_seconds`: Video duration
- `frames_extracted`: Number of frames extracted
- `extraction_fps`: Frame extraction rate
- `tournament_rounds`: Selection rounds completed
- `duration_seconds`: Total execution time
- `success`: Success indicator (1 or 0)

## MLflow UI Features

### Experiments View
- List of all procedure runs
- Sort by date, duration, success
- Filter by procedure name or status

### Run Details
- Complete parameter list
- Metrics timeline
- Artifacts (logs, results)
- System metrics

### Comparison View
- Compare multiple runs side-by-side
- Identify performance trends
- Spot anomalies

### Search Examples

In the MLflow UI search bar:

```
# Find all successful runs
metrics.success = 1

# Find runs longer than 30 seconds
metrics.duration_seconds > 30

# Find close-issue runs
params.procedure_name = "close-issue"

# Find runs with specific issue
params.issue_number = "123"

# Find failed video processing
params.procedure_name = "extract-best-frame" AND metrics.success = 0
```

## Testing

Run the test script to verify MLflow integration:

```bash
# Run with uv to ensure mlflow is available
uv run --with mlflow python tracking/test_mlflow.py
```

This will:
1. Initialize MLflow tracking
2. Create sample runs for both procedures
3. Query and display recent runs
4. Verify UI accessibility

## Benefits

1. **Debugging**: Full execution history with errors and artifacts
2. **Performance Monitoring**: Track execution times and success rates
3. **Reproducibility**: Complete record of parameters and environment
4. **Observability**: Visual dashboard for all automation
5. **Career Value**: Industry-standard ML engineering tool experience

## Integration with Existing Procedures

The MLflow tracking is designed to wrap existing procedures without modification:

1. **Natural language invocation** remains unchanged
2. **Procedure logic** stays in markdown files
3. **MLflow tracking** is optional and non-intrusive
4. **Backwards compatible** with current workflow

## Next Steps

- [ ] Add real-time procedure hooks
- [ ] Implement metric alerts
- [ ] Create custom dashboards
- [ ] Add comparison reports
- [ ] Export metrics to other systems