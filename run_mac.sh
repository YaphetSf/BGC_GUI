#!/bin/bash
# Run SimpleBGC on macOS with serial port working properly!
# This script works on both Intel Macs and Apple Silicon Macs (using Rosetta 2)

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

if [ ! -d "$GUI_BASE_DIR" ]; then
    echo -e "${RED}ERROR: SimpleBGC_GUI directory not found!${NC}"
    echo "Expected to find the official SimpleBGC GUI extracted under:"
    echo "  $GUI_BASE_DIR"
    echo ""
    echo "Download the macOS package from Basecam, extract it, and move the"
    echo "extracted folder (e.g. SimpleBGC_GUI_x_xx_x) into SimpleBGC_GUI/."
    exit 1
fi

JAR_PATH=$(find "$GUI_BASE_DIR" -maxdepth 2 -type f -name "SimpleBGC_GUI.jar" 2>/dev/null | sort | head -n 1)

if [ -z "$JAR_PATH" ]; then
    echo -e "${RED}ERROR: SimpleBGC_GUI.jar not found inside SimpleBGC_GUI/.${NC}"
    echo "Make sure you extracted the official GUI files into:"
    echo "  $GUI_BASE_DIR"
    echo "The folder should contain SimpleBGC_GUI.jar (e.g. SimpleBGC_GUI_x_xx_x/SimpleBGC_GUI.jar)."
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

# Try to find x86_64 Java 8
JAVA_FOUND=0
echo "Looking for x86_64 Java installation..."

# List of Java 8 paths to check (x86_64 builds only)
JAVA_PATHS=(
    "/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/bin/java"
    "/usr/local/bin/java"
)

for JAVA_PATH in "${JAVA_PATHS[@]}"; do
    if [ -f "$JAVA_PATH" ]; then
        # Check if it's x86_64 Java
        FILE_TYPE=$(file "$JAVA_PATH" 2>/dev/null)
        if echo "$FILE_TYPE" | grep -q "x86_64"; then
            JAVA_VERSION_LINE=$("$JAVA_PATH" -version 2>&1 | head -n 1)
            if echo "$JAVA_VERSION_LINE" | grep -Eq '"1\.8\.|"8\.'; then
                JAVA_CMD="$JAVA_PATH"
                JAVA_FOUND=1
                echo -e "${GREEN}Found x86_64 Java 8 at:${NC}"
                echo "  $JAVA_PATH"
                echo "  $JAVA_VERSION_LINE"
                echo ""
                break
            fi
        fi
    fi
done

if [ $JAVA_FOUND -eq 0 ]; then
    echo -e "${RED}ERROR: Could not find x86_64 Java installation!${NC}"
    echo ""
    echo "Please install x86_64 Java 8:"
    echo ""
    echo "1. Download from: https://adoptium.net/temurin/releases/?version=8"
    echo "2. Choose: ${YELLOW}Temurin 8 • macOS • x64 .pkg${NC} (NOT ARM64)"
    echo "3. Install the package"
    echo "4. Run this script again"
    echo ""
    echo "For detailed instructions, see: ../INSTALLATION_MAC.md"
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
    arch -x86_64 "$JAVA_CMD" \
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
