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
BROWSER_OPTS="--force-device-scale-factor=1.5 --no-sandbox --kiosk --disable-restore-session-state --noerrdialogs --start-fullscreen --autoplay-policy=no-user-gesture-required --check-for-update-interval=604800 --disable-pinch --overscroll-history-navigation=0 --disable-features=TranslateUI --disable-infobars --disable-notifications --no-first-run"

# Remote management options
ENABLE_REMOTE_RESTART=true     # Allow browser restart via SSH
REMOTE_RESTART_KEY="F5"        # Key to restart browser if using keyboard

# Display settings
DISABLE_SCREENSAVER=true
HIDE_CURSOR=true
DISABLE_DPMS=true  # Display Power Management Signaling

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

# Sleep for a moment to ensure X is fully started
sleep 2

#-------------------------------------------------------------------------------
# LAUNCH DASHBOARD
#-------------------------------------------------------------------------------

# Launch Chromium in kiosk mode
chromium-browser $BROWSER_OPTS "$DASHBOARD_URL" > /tmp/kiosk.log 2>&1 &

# Keep the session alive
while true; do
    sleep 60
done
