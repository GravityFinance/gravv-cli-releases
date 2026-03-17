#!/bin/bash
#
# gravv-cli installer
# Usage: curl -fsSL https://raw.githubusercontent.com/GravityFinance/gravv-cli-releases/main/install.sh | bash
#
# Environment variables:
#   GRAVV_INSTALL_DIR - Installation directory (default: /usr/local/bin)
#   GRAVV_VERSION     - Specific version to install (default: latest)
#

set -euo pipefail

# Configuration
GITHUB_OWNER="GravityFinance"
GITHUB_REPO="gravv-cli-releases"
BINARY_NAME="gravv"
INSTALL_DIR="${GRAVV_INSTALL_DIR:-/usr/local/bin}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Detect OS
detect_os() {
    local os
    os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    
    case "$os" in
        linux*)  echo "linux" ;;
        darwin*) echo "darwin" ;;
        mingw*|msys*|cygwin*) echo "windows" ;;
        *)       error "Unsupported operating system: $os" ;;
    esac
}

# Detect architecture
detect_arch() {
    local arch
    arch="$(uname -m)"
    
    case "$arch" in
        x86_64|amd64)  echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        *)             error "Unsupported architecture: $arch" ;;
    esac
}

# Get the latest release version from GitHub API
get_latest_version() {
    local api_url="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest"
    local version
    
    if command -v curl &> /dev/null; then
        version=$(curl -fsSL "$api_url" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    elif command -v wget &> /dev/null; then
        version=$(wget -qO- "$api_url" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    else
        error "Neither curl nor wget found. Please install one of them."
    fi
    
    if [ -z "$version" ]; then
        error "Could not determine latest version. Please check your internet connection or specify GRAVV_VERSION."
    fi
    
    # Remove 'v' prefix if present
    echo "${version#v}"
}

# Download file
download() {
    local url="$1"
    local output="$2"
    
    info "Downloading from $url..."
    
    if command -v curl &> /dev/null; then
        if ! curl -fsSL "$url" -o "$output"; then
            error "Failed to download $url"
        fi
    elif command -v wget &> /dev/null; then
        if ! wget -q "$url" -O "$output"; then
            error "Failed to download $url"
        fi
    else
        error "Neither curl nor wget found. Please install one of them."
    fi
}

# Verify checksum
verify_checksum() {
    local file="$1"
    local checksums_file="$2"
    local expected_name="$3"
    
    info "Verifying checksum..."
    
    local expected_checksum
    expected_checksum=$(grep "$expected_name" "$checksums_file" 2>/dev/null | awk '{print $1}')
    
    if [ -z "$expected_checksum" ]; then
        warn "Could not find checksum for $expected_name in checksums file"
        return 0
    fi
    
    local actual_checksum
    if command -v sha256sum &> /dev/null; then
        actual_checksum=$(sha256sum "$file" | awk '{print $1}')
    elif command -v shasum &> /dev/null; then
        actual_checksum=$(shasum -a 256 "$file" | awk '{print $1}')
    else
        warn "sha256sum/shasum not found, skipping checksum verification"
        return 0
    fi
    
    if [ "$expected_checksum" != "$actual_checksum" ]; then
        error "Checksum verification failed!
Expected: $expected_checksum
Actual:   $actual_checksum"
    fi
    
    success "Checksum verified"
}

# Install shell completions
install_completions() {
    local extract_dir="$1"
    
    # Check if completion files exist
    local completions_dir="$extract_dir/scripts/completions"
    if [ ! -d "$completions_dir" ]; then
        completions_dir="$extract_dir/completions"
    fi
    
    if [ ! -d "$completions_dir" ]; then
        return 0
    fi
    
    info "Installing shell completions..."
    
    # Bash completions
    if [ -f "$completions_dir/gravv.bash" ]; then
        local bash_dir="/etc/bash_completion.d"
        if [ -d "$bash_dir" ] && [ -w "$bash_dir" ]; then
            cp "$completions_dir/gravv.bash" "$bash_dir/gravv"
            success "Bash completions installed"
        elif [ -d "$bash_dir" ]; then
            sudo cp "$completions_dir/gravv.bash" "$bash_dir/gravv" 2>/dev/null || true
        fi
    fi
    
    # Zsh completions
    if [ -f "$completions_dir/gravv.zsh" ]; then
        local zsh_dir="/usr/local/share/zsh/site-functions"
        if [ -d "$zsh_dir" ] && [ -w "$zsh_dir" ]; then
            cp "$completions_dir/gravv.zsh" "$zsh_dir/_gravv"
            success "Zsh completions installed"
        fi
    fi
    
    # Fish completions
    if [ -f "$completions_dir/gravv.fish" ]; then
        local fish_dir="$HOME/.config/fish/completions"
        if [ -d "$HOME/.config/fish" ]; then
            mkdir -p "$fish_dir"
            cp "$completions_dir/gravv.fish" "$fish_dir/gravv.fish"
            success "Fish completions installed"
        fi
    fi
}

# Main installation function
install_gravv() {
    local os arch version archive_name archive_ext download_url checksums_url
    
    # Detect platform
    os=$(detect_os)
    arch=$(detect_arch)
    
    info "Detected platform: ${CYAN}$os/$arch${NC}"
    
    # Check for unsupported combinations
    if [ "$os" = "windows" ] && [ "$arch" = "arm64" ]; then
        error "Windows ARM64 is not supported"
    fi
    
    # Get version
    if [ -n "${GRAVV_VERSION:-}" ]; then
        version="${GRAVV_VERSION#v}"  # Remove v prefix if present
        info "Installing specified version: ${CYAN}$version${NC}"
    else
        info "Fetching latest version..."
        version=$(get_latest_version)
        info "Latest version: ${CYAN}$version${NC}"
    fi
    
    # Determine archive format
    if [ "$os" = "windows" ]; then
        archive_ext="zip"
    else
        archive_ext="tar.gz"
    fi
    
    # Build archive name (matches GoReleaser naming)
    archive_name="gravv_${version}_${os}_${arch}.${archive_ext}"
    
    # Build download URLs
    download_url="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download/v${version}/${archive_name}"
    checksums_url="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download/v${version}/checksums.txt"
    
    # Create temporary directory
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT
    
    # Download archive and checksums
    local archive_path="$tmp_dir/$archive_name"
    local checksums_path="$tmp_dir/checksums.txt"
    
    download "$download_url" "$archive_path"
    download "$checksums_url" "$checksums_path"
    
    # Verify checksum
    verify_checksum "$archive_path" "$checksums_path" "$archive_name"
    
    # Extract archive
    info "Extracting archive..."
    local extract_dir="$tmp_dir/extracted"
    mkdir -p "$extract_dir"
    
    if [ "$archive_ext" = "zip" ]; then
        if command -v unzip &> /dev/null; then
            unzip -q "$archive_path" -d "$extract_dir"
        else
            error "unzip not found. Please install unzip."
        fi
    else
        tar -xzf "$archive_path" -C "$extract_dir"
    fi
    
    # Find the binary
    local binary_path
    binary_path=$(find "$extract_dir" -name "$BINARY_NAME" -type f -perm -111 2>/dev/null | head -1)
    
    if [ -z "$binary_path" ]; then
        # Try without executable permission check
        binary_path=$(find "$extract_dir" -name "$BINARY_NAME" -type f | head -1)
    fi
    
    if [ -z "$binary_path" ]; then
        # Try with .exe extension for Windows
        binary_path=$(find "$extract_dir" -name "${BINARY_NAME}.exe" -type f | head -1)
    fi
    
    if [ -z "$binary_path" ]; then
        error "Could not find $BINARY_NAME binary in archive"
    fi
    
    # Create install directory if it doesn't exist
    if [ ! -d "$INSTALL_DIR" ]; then
        info "Creating install directory: $INSTALL_DIR"
        if [ -w "$(dirname "$INSTALL_DIR")" ]; then
            mkdir -p "$INSTALL_DIR"
        else
            sudo mkdir -p "$INSTALL_DIR"
        fi
    fi
    
    # Install binary
    info "Installing to $INSTALL_DIR..."
    
    local target_path="$INSTALL_DIR/$BINARY_NAME"
    if [ "$os" = "windows" ]; then
        target_path="$INSTALL_DIR/${BINARY_NAME}.exe"
    fi
    
    # Check if we need sudo
    if [ -w "$INSTALL_DIR" ]; then
        cp "$binary_path" "$target_path"
        chmod +x "$target_path"
    else
        warn "Elevated permissions required to install to $INSTALL_DIR"
        sudo cp "$binary_path" "$target_path"
        sudo chmod +x "$target_path"
    fi
    
    # Install completions
    install_completions "$extract_dir"
    
    # Verify installation
    echo ""
    if command -v "$BINARY_NAME" &> /dev/null; then
        success "gravv installed successfully!"
        echo ""
        "$BINARY_NAME" version
        echo ""
        echo -e "${CYAN}Quick Start:${NC}"
        echo "  gravv login      - Authenticate with your API keys"
        echo "  gravv tui        - Launch interactive terminal UI"
        echo "  gravv --help     - Show all available commands"
        echo ""
        echo -e "${CYAN}Shell Completions:${NC}"
        echo "  gravv completion bash > /etc/bash_completion.d/gravv"
        echo "  gravv completion zsh > \"\${fpath[1]}/_gravv\""
        echo "  gravv completion fish > ~/.config/fish/completions/gravv.fish"
    else
        warn "gravv was installed to $INSTALL_DIR but is not in your PATH"
        echo ""
        echo "Add to your PATH by running one of:"
        echo ""
        echo "  # Bash (~/.bashrc)"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        echo ""
        echo "  # Zsh (~/.zshrc)"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        echo ""
        echo "  # Fish (~/.config/fish/config.fish)"
        echo "  set -gx PATH $INSTALL_DIR \$PATH"
    fi
}

# Run installation
main() {
    echo ""
    echo -e "${CYAN}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║         gravv-cli installer           ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
    
    install_gravv
    echo ""
}

main "$@"
