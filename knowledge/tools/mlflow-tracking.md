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

MLflow tracking wraps our automation procedures to provide observability:
- Implementation: `tracking/mlflow_tracker.py`
- Procedures tracked: See `knowledge/procedures/`

## Using MLflow

- **UI**: http://localhost:5000 after running `mlflow ui`
- **Query API**: See `query_runs()` in `tracking/mlflow_tracker.py`
- **Search examples**: `metrics.success = 1`, `params.issue_number = "123"`

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