#!/bin/bash
set -e

# Flameshot build and install script
# Supports COSMIC desktop on Wayland

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
INSTALL_PREFIX="${1:-/usr}"
JOBS="${2:-$(nproc)}"

echo "=== Flameshot Build & Install Script ==="
echo "Install prefix: ${INSTALL_PREFIX}"
echo "Build jobs: ${JOBS}"
echo ""

# Check for required dependencies
check_dependencies() {
    local missing=()

    if ! command -v cmake &> /dev/null; then
        missing+=("cmake")
    fi

    if ! command -v make &> /dev/null; then
        missing+=("build-essential")
    fi

    if ! pkg-config --exists Qt6Core 2>/dev/null; then
        missing+=("qt6-base-dev")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        echo "Missing dependencies: ${missing[*]}"
        echo ""
        echo "Install them with:"
        echo "  sudo apt install ${missing[*]} qt6-base-dev qt6-svg-dev qt6-tools-dev qt6-l10n-tools g++"
        exit 1
    fi
}

echo "Checking dependencies..."
check_dependencies
echo "Dependencies OK"
echo ""

# Clean and create build directory
echo "Preparing build directory..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Configure
echo "Configuring with CMake..."
cmake .. \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release

# Build
echo ""
echo "Building with ${JOBS} jobs..."
make -j"${JOBS}"

# Install
echo ""
echo "Installing (requires sudo)..."
sudo make install

echo ""
echo "=== Installation complete ==="
echo "Run 'flameshot gui' to take a screenshot"
