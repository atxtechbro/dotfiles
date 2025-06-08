#!/bin/bash

# GitHub Actions Runner Service Installation Script
# Creates and manages a systemd service for GitHub Actions self-hosted runner
# Part of the development/ci-runner use case for Raspberry Pi
#
# COMPLETE SETUP PROCESS:
# =======================
#
# 1. First, install and configure the GitHub Actions runner:
#    - Go to your GitHub repository → Settings → Actions → Runners
#    - Click "New self-hosted runner" and select Linux/ARM64
#    - Follow the provided commands to download and configure the runner:
#      mkdir actions-runner && cd actions-runner
#      curl -o actions-runner-linux-arm64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz
#      tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz
#      ./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN
#
# 2. Test the runner manually first:
#    ./run.sh
#    (Ctrl+C to stop after verifying it connects successfully)
#
# 3. Run this script to install as a systemd service:
#    ./install-runner-service.sh
#
# WHAT THIS SCRIPT DOES:
# ======================
# - Creates a systemd service that automatically starts the runner on boot
# - Ensures the runner stays running (restarts if it crashes)
# - Makes the runner available 24/7 to serve GitHub Action job requests
# - Provides proper logging and status monitoring capabilities
#
# AFTER INSTALLATION:
# ===================
# The runner will:
# - Start automatically when the Pi boots up
# - Stay running in the background
# - Automatically restart if it crashes or stops
# - Be ready to accept and execute GitHub Actions workflows
# - Show as "Idle" in your GitHub repository's Actions → Runners page
#
# MONITORING:
# ===========
# - Check status: sudo systemctl status github-runner
# - View logs: sudo journalctl -u github-runner -f
# - Restart: sudo systemctl restart github-runner

set -e

SERVICE_FILE=/etc/systemd/system/github-runner.service
RUNNER_DIR=/home/pi/actions-runner

echo "Installing GitHub Actions Runner as systemd service..."

# Check if runner directory exists
if [[ ! -d "$RUNNER_DIR" ]]; then
    echo "Error: GitHub Actions runner directory not found at $RUNNER_DIR"
    echo "Please install the GitHub Actions runner first."
    exit 1
fi

# Create systemd service file if it doesn't exist
if [[ ! -f $SERVICE_FILE ]]; then
    echo "Creating systemd service for GitHub runner..."

    sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
ExecStart=$RUNNER_DIR/run.sh
WorkingDirectory=$RUNNER_DIR
User=pi
Restart=always
RestartSec=10
Environment=RUNNER_ALLOW_RUNASROOT=1

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable the service
    sudo systemctl daemon-reload
    sudo systemctl enable github-runner
    sudo systemctl start github-runner

    echo "✅ Runner service installed and started."
    echo "Service status:"
    sudo systemctl status github-runner --no-pager -l
else
    echo "⚠️  Runner service already exists. Checking status..."
    sudo systemctl status github-runner --no-pager -l
fi

echo ""
echo "Useful commands:"
echo "  sudo systemctl status github-runner    # Check service status"
echo "  sudo systemctl restart github-runner   # Restart the service"
echo "  sudo systemctl stop github-runner      # Stop the service"
echo "  sudo journalctl -u github-runner -f    # View live logs"
