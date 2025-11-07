#!/bin/bash
# Run SimpleBGC GUI 2.73.8 on macOS
# This script works on both Intel Macs and Apple Silicon Macs (using Rosetta 2)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "SimpleBGC GUI 2.73.8 Launcher for macOS"
echo "=========================================="
echo ""

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if jar file exists
if [ ! -f "SimpleBGC_GUI.jar" ]; then
    echo -e "${RED}ERROR: SimpleBGC_GUI.jar not found!${NC}"
    echo "Please run this script from the SimpleBGC_GUI_2_73_8 directory"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"
echo ""

# Try to find Java 8 first, then other versions
JAVA_FOUND=0
echo "Looking for x86_64 Java installation..."

# List of Java paths to check (x86_64 versions only)
JAVA_PATHS=(
    "/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/bin/java"
    "/Library/Java/JavaVirtualMachines/adoptopenjdk-17.jdk/Contents/Home/bin/java"
    "/usr/local/bin/java"
)

for JAVA_PATH in "${JAVA_PATHS[@]}"; do
    if [ -f "$JAVA_PATH" ]; then
        # Check if it's x86_64 Java
        FILE_TYPE=$(file "$JAVA_PATH" 2>/dev/null)
        if echo "$FILE_TYPE" | grep -q "x86_64"; then
            JAVA_CMD="$JAVA_PATH"
            JAVA_FOUND=1
            echo -e "${GREEN}Found x86_64 Java at:${NC}"
            echo "  $JAVA_PATH"
            
            # Show version info
            JAVA_VERSION=$("$JAVA_CMD" -version 2>&1 | head -1)
            echo "  $JAVA_VERSION"
            echo ""
            break
        fi
    fi
done

if [ $JAVA_FOUND -eq 0 ]; then
    echo -e "${RED}ERROR: Could not find x86_64 Java installation!${NC}"
    echo ""
    echo "Please install x86_64 Java 8 or higher:"
    echo ""
    echo "1. Download from: https://www.azul.com/downloads/?package=jdk"
    echo "2. Choose: ${YELLOW}x64 macOS DMG Installer${NC} (NOT ARM64)"
    echo "3. Install the DMG file"
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
echo -e "${GREEN}Starting SimpleBGC GUI 2.73.8...${NC}"
echo "=========================================="
echo ""

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

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Application closed successfully${NC}"
else
    echo -e "${RED}Application exited with error code: $EXIT_CODE${NC}"
fi

exit $EXIT_CODE
