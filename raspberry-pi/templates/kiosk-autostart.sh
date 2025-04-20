#\!/bin/bash
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
  
  sed -i "s < /dev/null | DASHBOARD_URL=\".*\"|DASHBOARD_URL=\"$1\"|" ~/.xinitrc
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
      current_url=$(grep "DASHBOARD_URL" ~/.xinitrc | cut -d'"' -f2)
      echo "Current URL: $current_url"
    else
      echo "Kiosk is not running"
    fi
    ;;
  *)
    echo "Usage: $(basename $0) [restart|update-url URL|status]"
    echo "  restart     - Restart the kiosk browser"
    echo "  update-url  - Change the dashboard URL"
    echo "  status      - Check if kiosk is running"
    ;;
esac
