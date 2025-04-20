#!/bin/bash
# Kiosk management script for headless operation
# To be installed in /usr/local/bin/kiosk-manager

function restart_kiosk() {
  pkill chromium
  sleep 2
  # If running via SSH, start in a new process that will survive SSH disconnect
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    nohup startx >/dev/null 2>&1 &
  else
    startx
  fi
}

function update_url() {
  if [ -z "$1" ]; then
    echo "Error: URL required"
    echo "Usage: $(basename $0) update-url https://example.com"
    exit 1
  fi
  
  # Store URL in separate file for persistence across template updates
  echo "$1" > ~/.dashboard_url
  echo "Dashboard URL updated to: $1"
  
  read -p "Restart kiosk now? (y/n): " choice
  case "$choice" in
    y|Y ) restart_kiosk ;;
    * ) echo "Restart manually with: $(basename $0) restart" ;;
  esac
}

case "$1" in
  restart)
    restart_kiosk
    ;;
  update-url)
    update_url "$2"
    ;;
  status)
    if pgrep chromium >/dev/null; then
      echo "Kiosk is running"
      if [ -f ~/.dashboard_url ]; then
        echo "Current URL: $(cat ~/.dashboard_url)"
      else
        current_url=$(grep "DASHBOARD_URL=" ~/.xinitrc | head -1 | cut -d'"' -f2)
        echo "Current URL: $current_url"
      fi
    else
      echo "Kiosk is not running"
    fi
    ;;
  set-location)
    if [ -z "$2" ]; then
      echo "Error: Location required"
      echo "Usage: $(basename $0) set-location <city>"
      exit 1
    fi
    # Special handler for weather dashboard
    echo "https://wttr.in/$2" > ~/.dashboard_url
    echo "Weather location updated to: $2"
    read -p "Restart kiosk now? (y/n): " choice
    case "$choice" in
      y|Y ) restart_kiosk ;;
      * ) echo "Restart manually with: $(basename $0) restart" ;;
    esac
    ;;
  *)
    echo "Usage: $(basename $0) [restart|update-url URL|set-location CITY|status]"
    echo "  restart       - Restart the kiosk browser"
    echo "  update-url    - Change the dashboard URL"
    echo "  set-location  - Set weather location (for wttr.in)"
    echo "  status        - Check if kiosk is running"
    ;;
esac