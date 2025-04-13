# Step 2: Hardware Setup

<!-- 
DEFINITION OF DONE:
1. User has physically set up their Raspberry Pi with all necessary connections
2. User understands power requirements for their specific Pi model
3. User has properly assembled any included components (case, fan, heatsinks)
4. User has confirmed the Pi is powered on with normal boot indicators
5. User is ready to SSH into the Pi in the next step

INPUT CONTEXT:
- User has completed Step 1 (Prepare SD Card)
- User has either a Raspberry Pi 5 with CanaKit bundle or a Raspberry Pi 3B+
- WiFi is already configured on the SD card
- SSH is already enabled on the SD card
- Raspberry Pi OS Lite is installed on the SD card
- The Pi will be accessed headlessly (no monitor/keyboard)
-->

This guide covers the hardware setup for both the Raspberry Pi 5 with CanaKit components and the Raspberry Pi 3B+. Both will be accessed headlessly via SSH over WiFi.

## Raspberry Pi 5 with CanaKit Setup

### Components Assembly

1. ✅ **Apply heatsinks** to the main chips:
   - Largest heatsink: Main CPU/SoC (center of board)
   - Medium heatsink: RAM chip
   - Smallest heatsink: USB controller chip
   
   > **Note:** CanaKit heatsinks come with pre-applied thermal tape. Simply peel off the protective backing and press firmly onto the corresponding chip for 5-10 seconds.

2. ✅ **Install the fan**:
   - Connect the fan to GPIO pins 4 (5V) and 6 (GND)
   - The red wire connects to pin 4 (5V)
   - The black wire connects to pin 6 (GND)
   - Ensure the fan is oriented to blow air onto the heatsinks

3. ✅ **Assemble the case**:
   - Place the Pi on the bottom part of the case, aligning all ports with their cutouts
   - Attach the top part of the case, ensuring the fan fits properly
   - Secure with the included screws (typically 4 screws)

### Final Connections

1. ✅ Insert the prepared microSD card into the Pi's SD card slot (underside of the board)
2. ✅ Connect the CanaKit USB-C power supply (5.1V/3A) to the Pi
3. ✅ Verify the power indicator LED is on (red LED)
4. ✅ Wait for the Pi to boot (~60-90 seconds)

## Raspberry Pi 3B+ Setup

### Basic Setup

1. ✅ Insert the prepared microSD card into the Pi's SD card slot
2. ✅ Connect a suitable Micro USB power supply (5.1V/2.5A recommended)
3. ✅ Verify the power indicator LED is on (red LED)
4. ✅ Wait for the Pi to boot (~60-90 seconds)

### Optional Cooling (Recommended)

For the Raspberry Pi 3B+ without a kit:
- Consider adding aftermarket heatsinks to the CPU, RAM, and USB controller
- For extended operation, a small 5V fan connected to GPIO pins 4 and 6 is recommended

## Power Requirements Comparison

| Model | Connector Type | Recommended Power | Minimum Power |
|-------|---------------|-------------------|---------------|
| Pi 5 (CanaKit) | USB-C | 5.1V/3A | 5V/3A |
| Pi 3B+ | Micro USB | 5.1V/2.5A | 5V/2A |

## LED Indicators

### Raspberry Pi 5
- Red LED: Power indicator (should stay solid)
- Green LED: Activity indicator (will flash during boot and disk activity)
- Additional LEDs for network activity near Ethernet port

### Raspberry Pi 3B+
- Red LED: Power indicator (should stay solid)
- Green LED: Activity indicator (will flash during boot and disk activity)
- Yellow/Green LEDs on Ethernet port (if connected)

## Troubleshooting Power Issues

- **Blinking red LED**: Indicates insufficient power. Use the recommended power supply.
- **Rainbow screen** (if monitor connected): Power issue or SD card problem.
- **No LEDs**: Check power supply connection and try a different cable.

## Next Steps

Your Raspberry Pi should now be fully assembled, powered on, and booting. Proceed to [Step 3: First Boot](03-first-boot.md) to connect to your Pi via SSH.
