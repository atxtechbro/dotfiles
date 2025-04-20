# Smart TV Dashboard / Kiosk Mode

This guide will help you set up your Raspberry Pi as a minimalist, bloat-free kiosk dashboard for a smart TV experience. The setup uses a lightweight approach with Xinit rather than a full desktop environment.

## Prerequisites

- Raspberry Pi (3, 4, or 5) with Raspberry Pi OS Lite installed
- Display connected via HDMI
- Internet connection (wired or wireless)
- Keyboard/mouse (for initial setup)

## Installation

1. Update your system:
```bash
sudo apt update && sudo apt upgrade -y
```

2. Install required packages:
```bash
sudo apt install -y xorg xinit x11-xserver-utils unclutter chromium-browser
```

3. Create the symlinked `.xinitrc` file:
```bash
ln -sf /home/pi/ppv/pillars/dotfiles/raspberry-pi/templates/.xinitrc ~/.xinitrc
```

4. Set up autostart by editing the `.bash_profile`:
```bash
echo "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor" >> ~/.bash_profile
```

5. Optional: Configure auto-login for headless operation:
```bash
sudo raspi-config
# Select: System Options > Boot / Auto Login > Console Autologin
```

## Configuration

All dashboard configuration is managed through the `.xinitrc` file. You can customize:

- Dashboard URL (default is a minimalist dashboard)
- Refresh rate
- Screen timeout settings
- Key bindings for control

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
- **Keyboard control issues**: Check key bindings in `.xinitrc`

## Resources

- [Chromium Command Line Switches](https://peter.sh/experiments/chromium-command-line-switches/)
- [Raspberry Pi Display Configuration](https://www.raspberrypi.com/documentation/computers/config_txt.html#hdmi-configuration)