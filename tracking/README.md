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

The tracking module provides wrapper functions for our automation procedures. These wrappers integrate with the procedures defined in:
- [`knowledge/procedures/close-issue-procedure.md`](../knowledge/procedures/close-issue-procedure.md)
- [`knowledge/procedures/extract-best-frame-procedure.md`](../knowledge/procedures/extract-best-frame-procedure.md)

See [`mlflow_tracker.py`](mlflow_tracker.py) for the implementation details of `track_close_issue()` and `track_extract_best_frame()` functions.

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

The specific parameters and metrics tracked for each procedure are documented in the source code:
- **close-issue**: See `track_close_issue()` in [mlflow_tracker.py](mlflow_tracker.py)
- **extract-best-frame**: See `track_extract_best_frame()` in [mlflow_tracker.py](mlflow_tracker.py)

Both procedures track execution time, success status, and procedure-specific metrics as defined in their implementations.

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

The MLflow tracking wraps existing procedures without modification. See the source code for implementation:
- Wrapper functions: [`mlflow_tracker.py`](mlflow_tracker.py)
- Test/demo script: [`test_mlflow.py`](test_mlflow.py)
- Procedure definitions: [`knowledge/procedures/`](../knowledge/procedures/)

## Next Steps

- [ ] Add real-time procedure hooks
- [ ] Implement metric alerts
- [ ] Create custom dashboards
- [ ] Add comparison reports
- [ ] Export metrics to other systems