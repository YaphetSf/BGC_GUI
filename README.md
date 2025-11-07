# SimpleBGC GUI Launcher Helper

This repository wraps the official Basecam SimpleBGC GUI so you can launch it on macOS with a single script.

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


## Troubleshooting
- Ensure the extracted GUI folder remains intact; the script searches within `SimpleBGC_GUI/` for `SimpleBGC_GUI.jar`.
- See `Docs/INSTALLATION_MAC.md` for detailed Java installation steps.
- For other issues, check `Docs/TROUBLESHOOTING.md` or open an issue.

