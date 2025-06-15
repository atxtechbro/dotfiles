# GitHub Actions Development Workflow

When creating or modifying GitHub Actions workflows, test locally with `act` before pushing to get fast feedback and avoid broken CI builds.

Run `gh act` after each change to validate workflows locally, fix any errors immediately, then commit only working workflows. This follows the tracer bullets principle - rapid iteration with immediate feedback rather than slow trial-and-error through GitHub's CI system.
