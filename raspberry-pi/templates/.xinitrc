#!/bin/sh

# Kiosk mode configuration for Raspberry Pi
# This file should be symlinked to ~/.xinitrc

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------

# Dashboard URL - change this to your preferred dashboard
# You can override this by creating a ~/.dashboard_url file
DASHBOARD_URL="https://wttr.in/austin"

# Load custom URL if file exists
if [ -f "$HOME/.dashboard_url" ]; then
    DASHBOARD_URL=$(cat "$HOME/.dashboard_url")
fi

# Browser options
BROWSER_OPTS="--force-device-scale-factor=3 --no-sandbox --kiosk --disable-restore-session-state --noerrdialogs --start-fullscreen --autoplay-policy=no-user-gesture-required --check-for-update-interval=604800 --disable-pinch --overscroll-history-navigation=0 --disable-features=TranslateUI --disable-infobars --disable-notifications --no-first-run"

# Remote management options
ENABLE_REMOTE_RESTART=true     # Allow browser restart via SSH
REMOTE_RESTART_KEY="F5"        # Key to restart browser if using keyboard

# Display settings
DISABLE_SCREENSAVER=true
HIDE_CURSOR=true
DISABLE_DPMS=true  # Display Power Management Signaling

# GitHub Actions Runner path
ACTIONS_RUNNER_PATH="$HOME/actions-runner"

#-------------------------------------------------------------------------------
# SETUP
#-------------------------------------------------------------------------------

# Set X settings
xset -dpms          # Disable DPMS (Energy Star) features
xset s off          # Disable screen saver
xset s noblank      # Don't blank the screen

# Hide mouse cursor when inactive
if [ "$HIDE_CURSOR" = true ]; then
    unclutter -idle 0.1 -root &
fi

# Disable screen timeout if configured
if [ "$DISABLE_DPMS" = true ]; then
    xset dpms 0 0 0
fi

#-------------------------------------------------------------------------------
# START GITHUB ACTIONS RUNNER
#-------------------------------------------------------------------------------

# Check if GitHub Actions Runner is already running
RUNNER_RUNNING=0
if pgrep -f "actions-runner/run.sh" > /dev/null; then
    echo "GitHub Actions Runner is already running" >> /tmp/kiosk.log
    RUNNER_RUNNING=1
fi

# Start GitHub Actions Runner if it's not already running and the directory exists
if [ $RUNNER_RUNNING -eq 0 ] && [ -d "$ACTIONS_RUNNER_PATH" ] && [ -f "$ACTIONS_RUNNER_PATH/run.sh" ]; then
    echo "Starting GitHub Actions Runner..." >> /tmp/kiosk.log
    cd "$ACTIONS_RUNNER_PATH"
    ./run.sh >> /tmp/actions-runner.log 2>&1 &
    cd "$HOME"
    echo "GitHub Actions Runner started with PID: $!" >> /tmp/kiosk.log
elif [ $RUNNER_RUNNING -eq 0 ]; then
    echo "GitHub Actions Runner not found at $ACTIONS_RUNNER_PATH" >> /tmp/kiosk.log
fi

# Clear the log file to avoid it growing too large
if [ -f "/tmp/actions-runner.log" ]; then
    tail -1000 /tmp/actions-runner.log > /tmp/actions-runner.log.tmp
    mv /tmp/actions-runner.log.tmp /tmp/actions-runner.log
fi

# No terminal window - runner will operate silently in the background
# Log file is still available at /tmp/actions-runner.log if needed

# Sleep for a moment to ensure everything is started
sleep 2

#-------------------------------------------------------------------------------
# LAUNCH DASHBOARD
#-------------------------------------------------------------------------------

echo "Chromium launching with URL: $DASHBOARD_URL" >> /tmp/kiosk.log
echo "Browser flags: $BROWSER_OPTS" >> /tmp/kiosk.log

# Launch Chromium in kiosk mode
chromium-browser $BROWSER_OPTS "$DASHBOARD_URL" > /tmp/kiosk.log 2>&1 &

# Keep the session alive
while true; do
    sleep 60
done
