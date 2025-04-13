# Step 1: Prepare the microSD Card

Before you can set up your Raspberry Pi with our optimized configurations, you'll need to prepare a microSD card with the Raspberry Pi OS.

## Requirements

- A microSD card (16GB minimum, 32GB or larger recommended)
- A computer with a microSD card reader
- Internet connection to download the necessary software

## Instructions

### 1. Download and Install Raspberry Pi Imager

The Raspberry Pi Imager is the official tool for installing Raspberry Pi OS on your microSD card.

- **Windows/Mac/Linux**: Download from [raspberrypi.com/software](https://www.raspberrypi.com/software/)
- **Ubuntu/Debian**: `sudo apt install rpi-imager`
- **Arch Linux**: `sudo pacman -S rpi-imager`

### 2. Insert your microSD card into your computer

Make sure any important data on the card has been backed up, as this process will erase everything on the card.

### 3. Open Raspberry Pi Imager

Launch the application you installed in step 1.

### 4. Choose OS

Click on "CHOOSE OS" and select:
- Recommended: "Raspberry Pi OS (64-bit)" for Pi 3, 4, or 5
- For older models: "Raspberry Pi OS (32-bit)"

### 5. Choose Storage

Click on "CHOOSE STORAGE" and select your microSD card from the list.

### 6. Configure Advanced Options

Click the gear icon (⚙️) in the bottom right to access advanced options:

- **Set hostname**: This will be your Pi's network name (e.g., `raspberrypi.local`)
- **Enable SSH**: Check this option and set a password for secure remote access
- **Configure WiFi**: If you plan to use WiFi instead of ethernet, enter your network details
- **Set locale settings**: Configure timezone, keyboard layout, etc.

### 7. Write the Image

Click "WRITE" to begin the process. This will:
- Format the microSD card
- Write the Raspberry Pi OS to the card
- Verify the written data

This process may take several minutes depending on your computer and microSD card speed.

### 8. Safely Eject

When the process is complete, safely eject the microSD card from your computer.

## Next Steps

Your microSD card is now ready! Proceed to [Step 2: Hardware Setup](02-hardware-setup.md) to continue setting up your Raspberry Pi.

## Troubleshooting

- **Write Failed**: Try a different microSD card or card reader
- **Verification Failed**: The card may be counterfeit or damaged
- **Can't Find SD Card**: Make sure it's properly inserted and recognized by your computer
