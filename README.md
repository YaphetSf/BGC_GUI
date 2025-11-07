# SimpleBGC GUI MacOS Launcher Helper

**Running Basecam SimpleBGC on Apple Silicon and missing serial ports?**
Grab this repo and follow the steps below to get the official GUI working as a native MacOS APP and talking to your Basecam board easily!

## Setup

### Prepare your Basecam GUI

1. Download the official SimpleBGC GUI for macOS from [basecamelectronics.com/downloads](https://www.basecamelectronics.com/downloads/32bit/#latest).
2. Extract the downloaded archive (it will contain a folder such as `SimpleBGC_GUI_2_73_8`).
3. Copy the extracted folder into `SimpleBGC_GUI/` in this repository, so the JAR ends up at `SimpleBGC_GUI/SimpleBGC_GUI_2_73_8/SimpleBGC_GUI.jar`.

### Java Requirements

1. Install an x86_64 (Intel) Java runtime. The easiest option is Temurin from Adoptium:
   - Visit [adoptium.net/temurin/releases](https://adoptium.net/temurin/releases/?version=8).
   - Choose version 8, `macOS`, `x64`, and download the `.pkg` installer.
   - Follow the instruction on the installer.
2. On Apple Silicon Macs the script automatically invokes Rosetta (`arch -x86_64`) so the Intel JVM works correctly.

## Run

First time use, run this in terminal:

```bash
chmod +x run_mac.sh
./run_mac.sh
```

Afterwards on just call:

```bash
./run_mac.sh
```

## Level up your game
To use a native MacOS app, follow the steps below.
1. Open "Automator" App and "New Document"
2. Select "Application"
3. Search in "Action" for "Run shell script"
4. Copy and paste the following commands:
```bash
cd path/to/your/script
chmod +x run_mac.sh
./run_mac.sh
```
5. Press save once done.
