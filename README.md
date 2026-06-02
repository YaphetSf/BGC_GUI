# SimpleBGC GUI MacOS Launcher Helper

**Running Basecam SimpleBGC on Apple Silicon and missing serial ports?**
Grab this repo and follow the steps below to get the official GUI working as a native MacOS APP and talking to your Basecam board easily!

## Setup

### Basecam GUI package

This repo includes `SimpleBGC_GUI/SimpleBGC_GUI_2_74_3.zip`.
On first launch, `run_mac.sh` automatically extracts it into `SimpleBGC_GUI/` and starts `SimpleBGC_GUI.jar`.

### Java Requirements

For one-command install, no manual Java setup is needed. If no x86_64 Java runtime is found, `install.sh` automatically downloads Eclipse Temurin x64 JRE into `BGC_GUI/.java/` inside the install folder.

For manual run, install an x86_64 (Intel) Java runtime. The Java version does not need to be 8; newer versions such as 11, 17, 21, or 25 are also accepted.
   - Visit [adoptium.net/temurin/releases](https://adoptium.net/temurin/releases/).
   - Choose `macOS`, `x64`, and download the `.pkg` installer.
   - Do not choose `AArch64` / `ARM64`, because the Basecam GUI serial library is x86_64.
   - Follow the instructions in the installer.

On Apple Silicon Macs, `install.sh` installs Rosetta 2 if needed, and `run_mac.sh` invokes Rosetta (`arch -x86_64`) so the Intel JVM can load the serial library correctly.

## One-command install

Run this in Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/YaphetSf/BGC_GUI/main/install.sh | bash
```

This downloads the launcher helper repo into `BGC_GUI/` under the current Terminal folder, runs `chmod +x run_mac.sh`, and starts `run_mac.sh`.
It also creates `BGC_GUI/SimpleBGC GUI.app`, so you can launch the GUI by double-clicking the app later.

To install somewhere else:

```bash
curl -fsSL https://raw.githubusercontent.com/YaphetSf/BGC_GUI/main/install.sh | bash -s -- --dir ~/Applications/BGC_GUI
```

To update an existing install, run the command from the folder that contains `BGC_GUI/`, or pass that path with `--dir`.

To install without starting the launcher immediately:

```bash
curl -fsSL https://raw.githubusercontent.com/YaphetSf/BGC_GUI/main/install.sh | bash -s -- --no-run
```

To skip creating the macOS app launcher:

```bash
curl -fsSL https://raw.githubusercontent.com/YaphetSf/BGC_GUI/main/install.sh | bash -s -- --no-app
```

## Manual run

First time use, run this in terminal:

```bash
chmod +x run_mac.sh
./run_mac.sh
```

Afterwards on just call:

```bash
./run_mac.sh
```

## macOS app launcher

The installer automatically creates:

```bash
BGC_GUI/SimpleBGC GUI.app
```

Double-click it to launch SimpleBGC GUI without opening Terminal. Launcher logs are written to:

```bash
BGC_GUI/launcher.log
```
