# Smart TV Dashboard / Kiosk Mode

This guide will help you set up your Raspberry Pi as a minimalist, bloat-free kiosk dashboard for a smart TV experience. The setup uses a lightweight approach with Xinit rather than a full desktop environment.

## Prerequisites

- Raspberry Pi (3, 4, or 5) with Raspberry Pi OS Lite installed
- Display connected via HDMI
- Internet connection (wired or wireless)
- SSH access (no mouse/keyboard needed for setup)

## Installation (No Mouse Required)

1. Enable SSH if not already enabled:
```bash
# Create empty ssh file in boot partition to enable SSH on first boot
sudo touch /boot/ssh
# Or use raspi-config if already booted:
# sudo raspi-config # Navigate to Interface Options > SSH > Enable
```

2. Connect via SSH to perform all setup steps remotely:
```bash
ssh pi@raspberrypi.local # Default hostname, use IP if needed
```

3. Update your system:
```bash
sudo apt update && sudo apt upgrade -y
```

4. Install required packages:
```bash
sudo apt install -y xorg xinit x11-xserver-utils unclutter chromium-browser
```

5. Create the symlinked `.xinitrc` file:
```bash
ln -sf /home/pi/ppv/pillars/dotfiles/raspberry-pi/templates/.xinitrc ~/.xinitrc
```

6. Install the kiosk management script:
```bash
sudo cp /home/pi/ppv/pillars/dotfiles/raspberry-pi/templates/kiosk-autostart.sh /usr/local/bin/kiosk-manager
sudo chmod +x /usr/local/bin/kiosk-manager
```

7. Set up autostart by editing the `.bash_profile`:
```bash
echo "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor" >> ~/.bash_profile
```

8. Configure auto-login (required for headless operation):
```bash
sudo raspi-config nonint do_boot_behaviour B2
# This enables console autologin without needing menu navigation
```

## Configuration

The dashboard is highly configurable without editing configuration files:

### Default Weather Dashboard

The default configuration uses `wttr.in/austin` to display a weather dashboard. You can change the location using:

```bash
kiosk-manager set-location london
```

### Choosing a Different Dashboard

You can set any URL for your dashboard:

```bash
kiosk-manager update-url https://example.com/dashboard
```

### Persistent Configuration

Your dashboard URL is stored in `~/.dashboard_url` and persists across system updates. The basic configuration is in the `.xinitrc` file where you can customize:

- Browser options
- Screen timeout settings
- Cursor behavior
- Key bindings

Edit the configuration in the original template file to apply changes to all linked systems.

## Key Features

- No desktop environment overhead (lean Xinit approach)
- Automatic startup on boot
- Hidden cursor and clean interface
- Screen can be configured to sleep on schedule
- Key bindings for manual refresh/restart

## Troubleshooting

- **Screen goes blank**: Check power settings and HDMI configuration in `config.txt`
- **Browser fails to start**: Ensure all dependencies are installed
- **Setup doesn't work**: Connect via SSH to troubleshoot; check logs with `journalctl -xe`
- **Need to make changes**: All configuration can be done via SSH without requiring a mouse

## Headless Management

You can manage your kiosk display entirely via SSH using the included management script:

1. To restart the kiosk browser:
```bash
kiosk-manager restart
```

2. To change dashboard URL:
```bash
kiosk-manager update-url https://your-new-url.com
```

3. To change weather location (for wttr.in):
```bash
kiosk-manager set-location paris
```

4. To check kiosk status:
```bash
kiosk-manager status
```

5. To reboot the system:
```bash
sudo reboot
```

The management script handles all the complexities of running X applications over SSH and ensures a clean restart process. You never need to manually edit configuration files.

## Resources

- [Chromium Command Line Switches](https://peter.sh/experiments/chromium-command-line-switches/)
- [Raspberry Pi Display Configuration](https://www.raspberrypi.com/documentation/computers/config_txt.html#hdmi-configuration)