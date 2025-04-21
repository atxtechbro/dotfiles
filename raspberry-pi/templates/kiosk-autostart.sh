#!/bin/bash
# Kiosk management script for headless operation
# To be installed in /usr/local/bin/kiosk-manager

# Log file for debugging
LOG_FILE="/tmp/kiosk-manager.log"

function log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
  echo "$1"
}

function check_x_running() {
  if pgrep Xorg >/dev/null; then
    return 0  # X is running
  else
    return 1  # X is not running
  fi
}

function clear_x_locks() {
  log "Clearing any X locks..."
  
  # Remove X lock files if they exist
  if [ -f /tmp/.X0-lock ]; then
    sudo rm -f /tmp/.X0-lock
    log "Removed /tmp/.X0-lock"
  fi
  
  # Kill any stuck X processes
  if pgrep Xorg >/dev/null; then
    sudo pkill Xorg
    sleep 1
    log "Killed lingering X processes"
  fi
}

function stop_kiosk() {
  log "Stopping kiosk..."
  
  # Kill Chromium browser
  if pgrep chromium >/dev/null; then
    pkill chromium
    log "Killed Chromium browser"
    sleep 2
  fi
  
  # Kill X server if running
  if check_x_running; then
    sudo pkill Xorg
    log "Killed X server"
    sleep 1
  fi
  
  # Clean up any locks
  clear_x_locks
  
  log "Kiosk stopped"
}

function start_kiosk() {
  # First make sure everything is stopped
  stop_kiosk
  
  log "Starting kiosk..."
  
  # When starting via SSH, we need to use systemd service
  # This fixes the permission issues with accessing the console
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    log "Using systemd service to start kiosk"
    create_service_if_needed
    sudo systemctl restart kiosk.service
    sleep 3
    
    # Check if service started successfully
    if sudo systemctl is-active kiosk.service >/dev/null; then
      log "Kiosk service started successfully"
    else
      log "ERROR: Failed to start kiosk service"
      sudo systemctl status kiosk.service >> "$LOG_FILE"
    fi
  else
    log "Starting X server directly"
    startx -- -nocursor >/tmp/xorg.log 2>&1 &
    sleep 3
    
    if check_x_running; then
      log "Kiosk started successfully"
    else
      log "ERROR: Failed to start X server. Check /tmp/xorg.log for details"
      cat /tmp/xorg.log >> "$LOG_FILE"
    fi
  fi
}

function restart_kiosk() {
  log "Restarting kiosk..."
  stop_kiosk
  sleep 2
  start_kiosk
}

function update_url() {
  if [ -z "$1" ]; then
    log "Error: URL required"
    echo "Usage: $(basename $0) update-url https://example.com"
    return 1
  fi
  
  # Store URL in separate file for persistence across template updates
  echo "$1" > ~/.dashboard_url
  log "Dashboard URL updated to: $1"
  
  read -p "Restart kiosk now? (y/n): " choice
  case "$choice" in
    y|Y ) restart_kiosk ;;
    * ) log "Restart manually with: $(basename $0) restart" ;;
  esac
}

function create_service_if_needed() {
  SERVICE_FILE="/etc/systemd/system/kiosk.service"
  
  if [ -f "$SERVICE_FILE" ]; then
    log "Kiosk service already exists"
    return
  fi
  
  log "Creating kiosk systemd service"
  
  # Create systemd service file
  cat << EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Raspberry Pi Kiosk Mode
After=network.target

[Service]
Type=simple
User=pi
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/home/pi/.Xauthority"
ExecStartPre=/bin/sh -c "/usr/bin/sudo /bin/rm -f /tmp/.X0-lock"
ExecStart=/usr/bin/startx -- -nocursor
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable kiosk.service
  log "Kiosk service created and enabled"
}

function kiosk_status() {
  echo "=== Kiosk Status ==="
  
  # Check if X server is running
  if check_x_running; then
    echo "X server: Running"
  else
    echo "X server: Not running"
  fi
  
  # Check if systemd service is active
  if systemctl is-active kiosk.service >/dev/null 2>&1; then
    echo "Kiosk service: Active"
  else
    echo "Kiosk service: Inactive"
  fi
  
  # Check if Chromium is running
  if pgrep chromium >/dev/null; then
    echo "Chromium: Running"
    # Try to get the window ID to confirm it's visible
    if command -v xdotool >/dev/null && [ -n "$DISPLAY" ]; then
      window_id=$(xdotool search --name chromium | head -1)
      if [ -n "$window_id" ]; then
        echo "Window visible: Yes (ID: $window_id)"
      else
        echo "Window visible: No (browser may be running in background)"
      fi
    fi
  else
    echo "Chromium: Not running"
  fi
  
  # Show current URL
  if [ -f ~/.dashboard_url ]; then
    echo "Current URL: $(cat ~/.dashboard_url)"
  else
    current_url=$(grep "DASHBOARD_URL=" ~/.xinitrc | head -1 | cut -d'"' -f2)
    echo "Current URL: $current_url (default from .xinitrc)"
  fi
  
  # Check for X lock files
  if [ -f /tmp/.X0-lock ]; then
    echo "X lock file: Present (/tmp/.X0-lock)"
  else
    echo "X lock file: None"
  fi
  
  # Show system info
  echo "Display: $DISPLAY"
  echo "Log file: $LOG_FILE"
  
  # Check systemd service logs
  if systemctl status kiosk.service >/dev/null 2>&1; then
    echo "--- Last 5 lines of service logs ---"
    journalctl -u kiosk.service -n 5 --no-pager
  fi
}

case "$1" in
  start)
    start_kiosk
    ;;
  stop)
    stop_kiosk
    ;;
  restart)
    restart_kiosk
    ;;
  update-url)
    update_url "$2"
    ;;
  status)
    kiosk_status
    ;;
  set-location)
    if [ -z "$2" ]; then
      echo "Error: Location required"
      echo "Usage: $(basename $0) set-location <city>"
      exit 1
    fi
    # Special handler for weather dashboard
    echo "https://wttr.in/$2" > ~/.dashboard_url
    log "Weather location updated to: $2"
    read -p "Restart kiosk now? (y/n): " choice
    case "$choice" in
      y|Y ) restart_kiosk ;;
      * ) log "Restart manually with: $(basename $0) restart" ;;
    esac
    ;;
  clear-locks)
    clear_x_locks
    ;;
  install-service)
    create_service_if_needed
    echo "Kiosk service installed. To start it: sudo systemctl start kiosk.service"
    ;;
  *)
    echo "Usage: $(basename $0) [start|stop|restart|update-url URL|set-location CITY|status|clear-locks|install-service]"
    echo "  start         - Start the kiosk browser"
    echo "  stop          - Stop the kiosk browser"
    echo "  restart       - Restart the kiosk browser"
    echo "  update-url    - Change the dashboard URL"
    echo "  set-location  - Set weather location (for wttr.in)"
    echo "  status        - Check if kiosk is running"
    echo "  clear-locks   - Clear any X lock files (if X crashed)"
    echo "  install-service - Create and enable systemd service"
    ;;
esac