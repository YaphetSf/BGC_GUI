#!/bin/bash
# Run SimpleBGC on macOS with serial port working properly.
# The Basecam GUI serial library is x86_64, so Apple Silicon Macs must run an
# x86_64 Java runtime through Rosetta 2. The Java version itself is not fixed.

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "SimpleBGC GUI Launcher for macOS"
echo "=========================================="
echo ""

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Locate the SimpleBGC GUI assets
GUI_BASE_DIR="$SCRIPT_DIR/SimpleBGC_GUI"
BUNDLED_GUI_ZIP="$GUI_BASE_DIR/SimpleBGC_GUI_2_74_3.zip"

if [ ! -d "$GUI_BASE_DIR" ]; then
    echo -e "${RED}ERROR: SimpleBGC_GUI directory not found!${NC}"
    echo "Expected to find the official SimpleBGC GUI extracted under:"
    echo "  $GUI_BASE_DIR"
    echo ""
    echo "Download the macOS package from Basecam, extract it, and move the"
    echo "extracted folder (e.g. SimpleBGC_GUI_x_xx_x) into SimpleBGC_GUI/."
    exit 1
fi

find_gui_jar() {
    find "$GUI_BASE_DIR" -maxdepth 2 -type f -name "SimpleBGC_GUI.jar" 2>/dev/null | sort | head -n 1
}

JAR_PATH=$(find_gui_jar)

if [ -z "$JAR_PATH" ] && [ -f "$BUNDLED_GUI_ZIP" ]; then
    if ! command -v unzip >/dev/null 2>&1; then
        echo -e "${RED}ERROR: SimpleBGC GUI zip is bundled, but unzip is not available.${NC}"
        exit 1
    fi

    echo "SimpleBGC_GUI.jar not found. Extracting bundled GUI zip..."
    echo "  $BUNDLED_GUI_ZIP"
    echo ""

    unzip -q "$BUNDLED_GUI_ZIP" -d "$GUI_BASE_DIR"
    JAR_PATH=$(find_gui_jar)
fi

if [ -z "$JAR_PATH" ]; then
    echo -e "${RED}ERROR: SimpleBGC_GUI.jar not found inside SimpleBGC_GUI/.${NC}"
    echo "Expected either:"
    echo "  $BUNDLED_GUI_ZIP"
    echo "or an extracted GUI folder containing:"
    echo "  SimpleBGC_GUI_x_xx_x/SimpleBGC_GUI.jar"
    exit 1
fi

APP_DIR="$(dirname "$JAR_PATH")"

echo "Using application directory: $APP_DIR"
echo ""

GUI_FOLDER_NAME="$(basename "$APP_DIR")"
GUI_VERSION_DISPLAY="SimpleBGC GUI"
if [[ "$GUI_FOLDER_NAME" =~ SimpleBGC_GUI_(.+) ]]; then
    RAW_VERSION="${BASH_REMATCH[1]}"
    GUI_VERSION_DISPLAY="SimpleBGC GUI ${RAW_VERSION//_/.}"
fi

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"
echo ""

rosetta_available() {
    /usr/bin/arch -x86_64 /usr/bin/true >/dev/null 2>&1
}

ensure_rosetta() {
    if [ "$ARCH" != "arm64" ]; then
        return
    fi

    if rosetta_available; then
        return
    fi

    echo "Rosetta 2 is required to run x86_64 Java on Apple Silicon."
    echo "Installing Rosetta 2..."
    echo ""

    if [ ! -x /usr/sbin/softwareupdate ]; then
        echo -e "${RED}ERROR: softwareupdate command not found; cannot install Rosetta 2.${NC}"
        exit 1
    fi

    /usr/sbin/softwareupdate --install-rosetta --agree-to-license

    if ! rosetta_available; then
        echo -e "${RED}ERROR: Rosetta 2 is still not available after installation.${NC}"
        echo "Try running this manually, then start the launcher again:"
        echo "  softwareupdate --install-rosetta --agree-to-license"
        exit 1
    fi

    echo -e "${GREEN}Rosetta 2 is available.${NC}"
    echo ""
}

ensure_rosetta

if [ "$ARCH" = "arm64" ] && { [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; }; then
    echo -e "${YELLOW}WARNING: This looks like an SSH session.${NC}"
    echo "SimpleBGC GUI is a desktop Swing app and must run in a macOS desktop session."
    echo "The install is complete; run this on the Mac's local Terminal instead:"
    echo "  $SCRIPT_DIR/run_mac.sh"
    echo ""
    exit 2
fi

# Find any x86_64 Java runtime. Java 8, 11, 17, 21, 25, etc. are all accepted
# as long as the runtime can load the x86_64 serial native library bundled with
# SimpleBGC GUI.
JAVA_FOUND=0
JAVA_CMD=""
JAVA_CANDIDATES=()

echo "Looking for x86_64 Java installation..."

add_java_candidate() {
    local candidate="$1"

    if [ -z "$candidate" ] || [ ! -x "$candidate" ]; then
        return
    fi

    local existing
    for existing in "${JAVA_CANDIDATES[@]}"; do
        if [ "$existing" = "$candidate" ]; then
            return
        fi
    done

    JAVA_CANDIDATES+=("$candidate")
}

java_binary_supports_x86_64() {
    local java_path="$1"
    local file_type

    file_type=$(file -L "$java_path" 2>/dev/null)
    echo "$file_type" | grep -q "x86_64"
}

java_version_line() {
    if [ "$ARCH" = "arm64" ]; then
        /usr/bin/arch -x86_64 "$1" -version 2>&1 | head -n 1
    else
        "$1" -version 2>&1 | head -n 1
    fi
}

# Prefer the portable Java runtime installed by install.sh.
for JAVA_PATH in "$SCRIPT_DIR"/.java/*/Contents/Home/bin/java \
                 "$SCRIPT_DIR"/.java/*/*.jdk/Contents/Home/bin/java \
                 "$SCRIPT_DIR"/.java/*/bin/java; do
    add_java_candidate "$JAVA_PATH"
done

# Prefer an explicitly selected JAVA_HOME if it is usable.
if [ -n "$JAVA_HOME" ]; then
    add_java_candidate "$JAVA_HOME/bin/java"
fi

# Ask macOS for the preferred x86_64 JVM. This covers Temurin/Zulu/Oracle/etc.
# installed under /Library/Java/JavaVirtualMachines, including newer LTS builds.
JAVA_HOME_X64=$(/usr/libexec/java_home -a x86_64 2>/dev/null)
if [ -n "$JAVA_HOME_X64" ]; then
    add_java_candidate "$JAVA_HOME_X64/bin/java"
fi

# Also scan common JVM locations in case java_home is not aware of an install.
for JAVA_PATH in /Library/Java/JavaVirtualMachines/*/Contents/Home/bin/java \
                 /usr/local/bin/java \
                 /opt/homebrew/bin/java; do
    add_java_candidate "$JAVA_PATH"
done

for JAVA_PATH in "${JAVA_CANDIDATES[@]}"; do
    if java_binary_supports_x86_64 "$JAVA_PATH"; then
        JAVA_CMD="$JAVA_PATH"
        JAVA_FOUND=1
        JAVA_VERSION_LINE=$(java_version_line "$JAVA_CMD")
        echo -e "${GREEN}Found x86_64 Java at:${NC}"
        echo "  $JAVA_CMD"
        echo "  $JAVA_VERSION_LINE"
        echo ""
        break
    fi
done

if [ $JAVA_FOUND -eq 0 ]; then
    echo -e "${RED}ERROR: Could not find an x86_64 Java installation!${NC}"
    echo ""
    echo "The SimpleBGC GUI serial connection needs an x86_64 Java runtime."
    echo "ARM64-only Java installs can start Java apps, but cannot load the"
    echo "x86_64 serial library used by this GUI."
    echo ""
    echo "Install any x86_64 macOS Java runtime, for example:"
    echo "1. Download from: https://adoptium.net/temurin/releases/"
    echo "2. Choose: ${YELLOW}macOS • x64${NC} (NOT AArch64 / ARM64)"
    echo "3. Any suitable version is accepted, including 8, 11, 17, 21, or 25"
    echo "4. Install the package and run this script again"
    exit 1
fi

# Determine if we need to use Rosetta 2
USE_ROSETTA=0
if [ "$ARCH" = "arm64" ]; then
    USE_ROSETTA=1
fi

echo "=========================================="
echo -e "${GREEN}Starting ${GUI_VERSION_DISPLAY}...${NC}"
echo "=========================================="
echo ""

pushd "$APP_DIR" >/dev/null

# Run the Java application
if [ $USE_ROSETTA -eq 1 ]; then
    # Apple Silicon Mac: use Rosetta 2
    echo "Using Rosetta 2 to run x86_64 Java"
    echo ""
    /usr/bin/arch -x86_64 "$JAVA_CMD" \
        -Dsimplebgc_gui.SimpleBGC_GUIView.Logger.level=0 \
        -Djava.library.path="./lib" \
        -Dlog4j.configuration=log4j.properties \
        -Dgnu.io.rxtx.NoVersionOutput=true \
        -Dsun.java2d.dpiaware=false \
        -jar SimpleBGC_GUI.jar "$@"
else
    # Intel Mac: run directly
    "$JAVA_CMD" \
        -Dsimplebgc_gui.SimpleBGC_GUIView.Logger.level=0 \
        -Djava.library.path="./lib" \
        -Dlog4j.configuration=log4j.properties \
        -Dgnu.io.rxtx.NoVersionOutput=true \
        -Dsun.java2d.dpiaware=false \
        -jar SimpleBGC_GUI.jar "$@"
fi

EXIT_CODE=$?

popd >/dev/null

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Application closed successfully${NC}"
else
    echo -e "${RED}Application exited with error code: $EXIT_CODE${NC}"
fi

exit $EXIT_CODE
