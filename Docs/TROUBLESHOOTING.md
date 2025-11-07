# Troubleshooting SimpleBGC GUI on macOS

## Problem: `NoClassDefFoundError: Could not initialize class gnu.io.RXTXCommDriver`

This error occurs because you're running on an **Apple Silicon Mac (ARM64)** and the serial communication library (`nrjavaserial-5.2.1.jar`) only contains **x86_64** native libraries.

## Solution: Run with x86_64 Java

Since the native library is x86_64 only, you have two main options:

### Option 1: Install x86_64 Java (Recommended)

1. Download x86_64 Java:
   - Go to: https://www.azul.com/downloads/?package=jdk
   - Choose: **x64 macOS DMG Installer** (NOT ARM64)
   - Install it

2. Run the application:
   ```bash
   chmod +x run_x86.sh
   ./run_x86.sh
   ```

### Option 2: Install x86_64 Homebrew and Java

If you want to use Homebrew for x86_64 programs:

```bash
# Install x86_64 Homebrew
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install x86_64 Java
arch -x86_64 /usr/local/bin/brew install openjdk@17

# Run the app
./run_x86.sh
```

### Additional Setup Steps

1. **Create /var/lock directory** (Required by RXTX):
   ```bash
   sudo mkdir /var/lock
   sudo chmod 777 /var/lock
   ```

2. **Check serial port detection**:
   ```bash
   ls /dev/tty.*
   ```
   You should see your device (e.g., `/dev/tty.usbserial-0001`)

3. **Install USB drivers if needed**:
   - CP2102: http://www.silabs.com/products/mcu/pages/usbtouartbridgevcpdrivers.aspx
   - Or check your board manufacturer's website

## Alternative: Try Native ARM64 Solution (Advanced)

If you want to avoid Rosetta 2, you would need to:

1. Find or compile an ARM64 version of the serial library
2. Replace `nrjavaserial-5.2.1.jar` with the ARM64 version
3. Update the launch script

However, this is complex and there's no readily available ARM64 version of nrjavaserial at the time of writing.

## Why This Happens

- **Native libraries** (`.jnilib` files) are platform-specific
- `nrjavaserial` embeds native libraries inside the JAR
- The version in this app only has x86_64 native code
- When Java tries to load it on ARM64, it fails with `NoClassDefFoundError`

Running under Rosetta 2 with x86_64 Java works because:
- Rosetta 2 translates x86_64 → ARM64 instructions
- Your Java app and the native library both run as x86_64
- They're compatible with each other

## Still Having Issues?

1. Make sure Rosetta 2 is installed:
   ```bash
   arch -x86_64 uname -m  # Should print: x86_64
   ```

2. Verify x86_64 Java is used:
   ```bash
   arch -x86_64 /path/to/x86_64/java -version
   ```

3. Check serial port permissions:
   ```bash
   ls -l /dev/tty.usbserial-*
   ```

4. Try running with DEBUG_MODE:
   ```bash
   ./run_x86.sh DEBUG_MODE
   ```

