#!/bin/sh
#
# gravv-cli installer
#
#   curl -sSL https://get.gravv.xyz | sh
#
# This script is POSIX sh, not bash: it is piped straight into `sh`, so the
# shebang above is ignored by the usual invocation and nothing here may rely
# on bash features. Keep it that way -- `set -o pipefail`, `echo -e`, `[[ ]]`
# and `&>` all fail under dash, which is /bin/sh on most Linux distributions.
#
# Everything is defined as functions and `main` is called on the very last
# line, so a download truncated mid-flight cannot execute half an install.
#
# Environment variables:
#   GRAVV_VERSION       Version to install, with or without a leading v
#                       (default: whatever the latest release is)
#   GRAVV_INSTALL_DIR   Where to put the binary
#                       (default: /usr/local/bin, falling back to
#                       ~/.local/bin when that is not writable)
#   GRAVV_BASE_URL      Release artifact host, for mirrors and testing
#   GRAVV_NO_SUDO       Set to 1 to never escalate; installs to ~/.local/bin
#   GRAVV_SKIP_VERIFY   Set to 1 to skip checksum verification (discouraged)
#   NO_COLOR            Set to anything to disable coloured output
#

set -eu

BINARY_NAME="gravv"
BASE_URL="${GRAVV_BASE_URL:-https://gravv-cli.s3.us-east-1.amazonaws.com}"
FALLBACK_INSTALL_DIR="${HOME:-/tmp}/.local/bin"

# ---------------------------------------------------------------- output ---

setup_colors() {
    # Colour only when stdout is a terminal. Piping into `sh` leaves stdout
    # attached to the terminal, so this stays colourful in the normal case
    # while staying clean when redirected to a file or a log.
    if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
        C_RED=$(printf '\033[0;31m')
        C_GREEN=$(printf '\033[0;32m')
        C_YELLOW=$(printf '\033[1;33m')
        C_BLUE=$(printf '\033[0;34m')
        C_CYAN=$(printf '\033[0;36m')
        C_OFF=$(printf '\033[0m')
    else
        C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_CYAN='' C_OFF=''
    fi
}

info()    { printf '%s[info]%s %s\n' "$C_BLUE" "$C_OFF" "$1"; }
success() { printf '%s[ ok ]%s %s\n' "$C_GREEN" "$C_OFF" "$1"; }
warn()    { printf '%s[warn]%s %s\n' "$C_YELLOW" "$C_OFF" "$1" >&2; }

error() {
    printf '%s[fail]%s %s\n' "$C_RED" "$C_OFF" "$1" >&2
    exit 1
}

has() {
    command -v "$1" >/dev/null 2>&1
}

# ---------------------------------------------------------------- platform -

detect_os() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$os" in
        linux*)               echo "linux" ;;
        darwin*)              echo "darwin" ;;
        mingw*|msys*|cygwin*) echo "windows" ;;
        *)                    error "unsupported operating system: $os" ;;
    esac
}

detect_arch() {
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)  echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        *)             error "unsupported architecture: $arch" ;;
    esac
}

# ---------------------------------------------------------------- transfer -

# fetch_stdout URL -- prints the body, non-zero on failure.
fetch_stdout() {
    if has curl; then
        curl -fsSL "$1"
    elif has wget; then
        wget -qO- "$1"
    else
        error "neither curl nor wget is available; install one and retry"
    fi
}

# fetch_file URL DEST
fetch_file() {
    if has curl; then
        curl -fsSL "$1" -o "$2" || error "download failed: $1"
    elif has wget; then
        wget -q "$1" -O "$2" || error "download failed: $1"
    else
        error "neither curl nor wget is available; install one and retry"
    fi
}

resolve_version() {
    if [ -n "${GRAVV_VERSION:-}" ]; then
        # Accept both "0.1.9" and "v0.1.9".
        printf '%s\n' "${GRAVV_VERSION#v}"
        return 0
    fi

    version=$(fetch_stdout "$BASE_URL/releases/latest/version.txt" 2>/dev/null | tr -d ' \t\r\n') || version=''
    if [ -z "$version" ]; then
        error "could not determine the latest version from $BASE_URL; set GRAVV_VERSION to install a specific one"
    fi
    printf '%s\n' "${version#v}"
}

# ---------------------------------------------------------------- checksum -

sha256_of() {
    if has sha256sum; then
        sha256sum "$1" | awk '{print $1}'
    elif has shasum; then
        shasum -a 256 "$1" | awk '{print $1}'
    elif has openssl; then
        openssl dgst -sha256 "$1" | awk '{print $NF}'
    else
        return 1
    fi
}

verify_checksum() {
    archive_path=$1
    checksums_path=$2
    archive_file=$3

    if [ "${GRAVV_SKIP_VERIFY:-}" = "1" ]; then
        warn "skipping checksum verification because GRAVV_SKIP_VERIFY=1"
        return 0
    fi

    expected=$(awk -v name="$archive_file" '$2 == name || $2 == "*" name {print $1}' "$checksums_path" | head -n 1)
    if [ -z "$expected" ]; then
        error "no checksum published for $archive_file; refusing to install an unverified binary (set GRAVV_SKIP_VERIFY=1 to override)"
    fi

    if ! actual=$(sha256_of "$archive_path"); then
        error "no sha256 tool found (sha256sum, shasum or openssl); refusing to install an unverified binary (set GRAVV_SKIP_VERIFY=1 to override)"
    fi

    if [ "$expected" != "$actual" ]; then
        error "checksum mismatch for $archive_file
  expected: $expected
  actual:   $actual
The download may be corrupt or tampered with. Nothing was installed."
    fi

    success "checksum verified"
}

# ---------------------------------------------------------------- install --

# Decide where the binary goes and whether sudo is needed. Sets
# INSTALL_DIR and NEEDS_SUDO.
choose_install_dir() {
    NEEDS_SUDO=0

    if [ -n "${GRAVV_INSTALL_DIR:-}" ]; then
        INSTALL_DIR=$GRAVV_INSTALL_DIR
    elif [ "${GRAVV_NO_SUDO:-}" = "1" ]; then
        INSTALL_DIR=$FALLBACK_INSTALL_DIR
    else
        INSTALL_DIR=/usr/local/bin
    fi

    if [ -d "$INSTALL_DIR" ] && [ -w "$INSTALL_DIR" ]; then
        return 0
    fi

    # Not writable. Escalating is only reasonable when the caller has not
    # opted out and sudo actually exists; otherwise fall back to a directory
    # inside the user's home, which needs no privileges at all.
    if [ ! -d "$INSTALL_DIR" ]; then
        parent=$(dirname "$INSTALL_DIR")
        if [ -w "$parent" ]; then
            mkdir -p "$INSTALL_DIR"
            return 0
        fi
    fi

    if [ "$(id -u)" = "0" ]; then
        mkdir -p "$INSTALL_DIR"
        return 0
    fi

    if [ "${GRAVV_NO_SUDO:-}" != "1" ] && has sudo; then
        NEEDS_SUDO=1
        return 0
    fi

    if [ -n "${GRAVV_INSTALL_DIR:-}" ]; then
        error "$INSTALL_DIR is not writable and sudo is unavailable; pick a different GRAVV_INSTALL_DIR"
    fi

    warn "$INSTALL_DIR is not writable and sudo is unavailable; installing to $FALLBACK_INSTALL_DIR instead"
    INSTALL_DIR=$FALLBACK_INSTALL_DIR
    mkdir -p "$INSTALL_DIR"
}

place_binary() {
    src=$1
    dest=$2

    if [ "$NEEDS_SUDO" = "1" ]; then
        info "elevated permissions are required to write to $INSTALL_DIR"
        sudo mkdir -p "$INSTALL_DIR" || error "could not create $INSTALL_DIR"
        sudo cp "$src" "$dest" || error "could not install to $dest"
        sudo chmod 755 "$dest" || error "could not make $dest executable"
    else
        cp "$src" "$dest" || error "could not install to $dest"
        chmod 755 "$dest" || error "could not make $dest executable"
    fi
}

on_path() {
    case ":${PATH}:" in
        *":$1:"*) return 0 ;;
        *)        return 1 ;;
    esac
}

print_next_steps() {
    dest=$1

    printf '\n'
    success "gravv $VERSION installed to $dest"
    printf '\n'

    if on_path "$INSTALL_DIR"; then
        "$dest" version 2>/dev/null || true
        printf '\n'
        printf '%sNext steps%s\n' "$C_CYAN" "$C_OFF"
        printf '  gravv login     authenticate with your API key\n'
        printf '  gravv tui       launch the interactive terminal UI\n'
        printf '  gravv --help    list every command\n'
    else
        warn "$INSTALL_DIR is not on your PATH"
        printf '\n'
        printf 'Add it by appending this to your shell profile:\n\n'
        printf '  export PATH="%s:$PATH"\n\n' "$INSTALL_DIR"
        printf 'Or run gravv by its full path: %s\n' "$dest"
    fi
    printf '\n'
}

# -------------------------------------------------------------------- main -

install_gravv() {
    OS=$(detect_os)
    ARCH=$(detect_arch)

    if [ "$OS" = "windows" ]; then
        error "this installer does not support Windows; download the .zip from the releases page or use WSL"
    fi

    info "platform: $C_CYAN$OS/$ARCH$C_OFF"

    VERSION=$(resolve_version)
    info "version:  $C_CYAN$VERSION$C_OFF"

    archive_file="gravv_${VERSION}_${OS}_${ARCH}.tar.gz"
    archive_url="$BASE_URL/releases/v${VERSION}/${archive_file}"
    checksums_url="$BASE_URL/releases/v${VERSION}/checksums.txt"

    tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t gravv)
    [ -n "$tmp_dir" ] || error "could not create a temporary directory"
    trap 'rm -rf "$tmp_dir"' EXIT INT TERM

    info "downloading $archive_file"
    fetch_file "$archive_url" "$tmp_dir/$archive_file"
    fetch_file "$checksums_url" "$tmp_dir/checksums.txt"

    verify_checksum "$tmp_dir/$archive_file" "$tmp_dir/checksums.txt" "$archive_file"

    mkdir -p "$tmp_dir/unpacked"
    tar -xzf "$tmp_dir/$archive_file" -C "$tmp_dir/unpacked" \
        || error "could not extract $archive_file"

    binary_path=$(find "$tmp_dir/unpacked" -type f -name "$BINARY_NAME" | head -n 1)
    [ -n "$binary_path" ] || error "no $BINARY_NAME binary inside $archive_file"

    choose_install_dir
    dest="$INSTALL_DIR/$BINARY_NAME"
    place_binary "$binary_path" "$dest"

    print_next_steps "$dest"
}

main() {
    setup_colors

    printf '\n'
    printf '%s  gravv-cli installer%s\n' "$C_CYAN" "$C_OFF"
    printf '\n'

    install_gravv
}

main "$@"
