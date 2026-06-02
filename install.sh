#!/bin/bash
# One-command installer for the SimpleBGC GUI macOS launcher helper.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://github.com/YaphetSf/BGC_GUI.git"
ZIP_URL="https://github.com/YaphetSf/BGC_GUI/archive/refs/heads/main.zip"
DEFAULT_INSTALL_DIR="$HOME/BGC_GUI"
INSTALL_DIR="${BGC_GUI_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
TEMURIN_VERSION="${BGC_GUI_JAVA_VERSION:-25}"
TEMURIN_API_URL="https://api.adoptium.net/v3/binary/latest/${TEMURIN_VERSION}/ga/mac/x64/jre/hotspot/normal/eclipse"
RUN_AFTER_INSTALL=1

while [ $# -gt 0 ]; do
    case "$1" in
        --dir)
            if [ -z "$2" ]; then
                echo -e "${RED}ERROR: --dir needs a path.${NC}"
                exit 1
            fi
            INSTALL_DIR="$2"
            shift 2
            ;;
        --no-run)
            RUN_AFTER_INSTALL=0
            shift
            ;;
        --help|-h)
            echo "Usage: install.sh [--dir PATH] [--no-run]"
            echo ""
            echo "Environment:"
            echo "  BGC_GUI_INSTALL_DIR=/path/to/install"
            echo "  BGC_GUI_JAVA_VERSION=25"
            exit 0
            ;;
        *)
            echo -e "${RED}ERROR: Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo "=========================================="
echo "SimpleBGC GUI Launcher Installer"
echo "=========================================="
echo ""
echo "Install directory: $INSTALL_DIR"
echo ""

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

java_binary_supports_x86_64() {
    local java_path="$1"
    local file_type

    if [ -z "$java_path" ] || [ ! -x "$java_path" ]; then
        return 1
    fi

    file_type=$(file -L "$java_path" 2>/dev/null)
    echo "$file_type" | grep -q "x86_64"
}

find_x86_64_java() {
    local java_path
    local java_home_x64

    for java_path in "$INSTALL_DIR"/.java/*/Contents/Home/bin/java \
                     "$INSTALL_DIR"/.java/*/*.jdk/Contents/Home/bin/java \
                     "$INSTALL_DIR"/.java/*/bin/java; do
        if java_binary_supports_x86_64 "$java_path"; then
            echo "$java_path"
            return 0
        fi
    done

    if [ -n "$JAVA_HOME" ] && java_binary_supports_x86_64 "$JAVA_HOME/bin/java"; then
        echo "$JAVA_HOME/bin/java"
        return 0
    fi

    java_home_x64=$(/usr/libexec/java_home -a x86_64 2>/dev/null || true)
    if [ -n "$java_home_x64" ] && java_binary_supports_x86_64 "$java_home_x64/bin/java"; then
        echo "$java_home_x64/bin/java"
        return 0
    fi

    for java_path in /Library/Java/JavaVirtualMachines/*/Contents/Home/bin/java \
                     /usr/local/bin/java \
                     /opt/homebrew/bin/java; do
        if java_binary_supports_x86_64 "$java_path"; then
            echo "$java_path"
            return 0
        fi
    done

    return 1
}

install_portable_temurin() {
    local java_dir
    local tmp_dir
    local archive_path
    local java_path

    if ! command_exists curl || ! command_exists tar; then
        echo -e "${RED}ERROR: Need curl and tar to download portable Temurin Java.${NC}"
        exit 1
    fi

    java_dir="$INSTALL_DIR/.java"
    tmp_dir="$(mktemp -d)"
    archive_path="$tmp_dir/temurin-${TEMURIN_VERSION}-mac-x64-jre.tar.gz"

    mkdir -p "$java_dir"

    echo "No x86_64 Java runtime found."
    echo "Downloading Eclipse Temurin ${TEMURIN_VERSION} x64 JRE..."
    echo "  $TEMURIN_API_URL"
    echo ""

    curl -fL "$TEMURIN_API_URL" -o "$archive_path"
    tar -xzf "$archive_path" -C "$java_dir"

    java_path=$(find_x86_64_java || true)
    if [ -z "$java_path" ]; then
        echo -e "${RED}ERROR: Downloaded Temurin, but could not find an x86_64 java binary.${NC}"
        echo "Java directory: $java_dir"
        exit 1
    fi

    echo -e "${GREEN}Installed portable x86_64 Java:${NC}"
    echo "  $java_path"
    echo ""
}

ensure_x86_64_java() {
    local java_path

    java_path=$(find_x86_64_java || true)
    if [ -n "$java_path" ]; then
        echo -e "${GREEN}Found x86_64 Java:${NC}"
        echo "  $java_path"
        echo ""
        return
    fi

    install_portable_temurin
}

ensure_install_parent() {
    local parent_dir

    parent_dir="$(dirname "$INSTALL_DIR")"
    mkdir -p "$parent_dir"
}

download_with_git() {
    if [ -d "$INSTALL_DIR/.git" ]; then
        echo "Updating existing git checkout..."
        git -C "$INSTALL_DIR" pull --ff-only
        return
    fi

    if [ -e "$INSTALL_DIR" ]; then
        echo -e "${RED}ERROR: Install directory already exists but is not a git checkout:${NC}"
        echo "  $INSTALL_DIR"
        echo ""
        echo "Choose a different path:"
        echo "  curl -fsSL https://raw.githubusercontent.com/YaphetSf/BGC_GUI/main/install.sh | bash -s -- --dir ~/BGC_GUI_2"
        exit 1
    fi

    ensure_install_parent
    echo "Cloning launcher helper repo..."
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
}

download_with_zip() {
    local tmp_dir
    local zip_file
    local extracted_dir

    if [ -e "$INSTALL_DIR" ]; then
        echo -e "${RED}ERROR: Install directory already exists:${NC}"
        echo "  $INSTALL_DIR"
        echo ""
        echo "Install git if you want automatic updates, or choose a different --dir path."
        exit 1
    fi

    if ! command_exists curl || ! command_exists unzip; then
        echo -e "${RED}ERROR: Need git, or both curl and unzip.${NC}"
        exit 1
    fi

    tmp_dir="$(mktemp -d)"
    zip_file="$tmp_dir/BGC_GUI.zip"

    echo "Downloading launcher helper repo..."
    curl -fsSL "$ZIP_URL" -o "$zip_file"
    unzip -q "$zip_file" -d "$tmp_dir"

    extracted_dir="$tmp_dir/BGC_GUI-main"
    if [ ! -d "$extracted_dir" ]; then
        echo -e "${RED}ERROR: Downloaded archive did not contain BGC_GUI-main.${NC}"
        exit 1
    fi

    ensure_install_parent
    mv "$extracted_dir" "$INSTALL_DIR"
    rm -rf "$tmp_dir"
}

if command_exists git && download_with_git; then
    :
else
    download_with_zip
fi

if [ ! -f "$INSTALL_DIR/run_mac.sh" ]; then
    echo -e "${RED}ERROR: run_mac.sh was not found after install.${NC}"
    exit 1
fi

chmod +x "$INSTALL_DIR/run_mac.sh"

echo ""
echo -e "${GREEN}Launcher helper installed.${NC}"
echo "Run script: $INSTALL_DIR/run_mac.sh"
echo ""

ensure_x86_64_java

if [ "$RUN_AFTER_INSTALL" -eq 0 ]; then
    echo "Skipping launch because --no-run was passed."
    exit 0
fi

echo -e "${YELLOW}Starting launcher...${NC}"
echo "On first launch, the bundled SimpleBGC GUI zip will be extracted automatically."
echo ""

exec "$INSTALL_DIR/run_mac.sh"
