# MLflow Tracking

MLflow tracking is integrated into our automation procedures to provide observability, reproducibility, and debugging capabilities.

## Quick Start

```bash
# Install MLflow globally
uv tool install mlflow

# Start MLflow UI
mlflow ui --backend-store-uri ~/ppv/pillars/dotfiles/mlruns

# View at http://localhost:5000
```

## Tracking Integration

Our procedures automatically log to MLflow when executed:

- **close-issue**: Tracks issue details, implementation steps, PR creation
- **extract-best-frame**: Tracks video metadata, frame extraction, selection

## Using Tracked Data

### From MLflow UI

1. Open http://localhost:5000
2. Click "automation-procedures" experiment
3. View runs, metrics, and artifacts
4. Use search: `metrics.success = 1` or `params.issue_number = "123"`

### From Python

```python
from tracking.mlflow_tracker import query_runs

# Find failed runs
failed = query_runs("metrics.success = 0")

# Find slow runs
slow = query_runs("metrics.duration_seconds > 60")
```

## Benefits

- **Debugging**: See exactly what happened in failed runs
- **Performance**: Track execution times and optimize bottlenecks
- **Audit Trail**: Complete history of all automated actions
- **Career Value**: Demonstrate MLflow expertise (25M+ monthly downloads)

## Implementation Details

See `tracking/` directory for:
- `mlflow_tracker.py`: Core tracking implementation
- `test_mlflow.py`: Test and demo script
- `README.md`: Detailed documentation