#!/bin/bash

# GitHub Actions Runner Service Installation Script
# Creates and manages a systemd service for GitHub Actions self-hosted runner
# Part of the development/ci-runner use case for Raspberry Pi

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
