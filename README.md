# gravv-cli-releases

Public release repository for [gravv-cli](https://github.com/GravityFinance/gravv-cli) - a CLI/TUI tool for the Gravv financial payments platform.

## Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/GravityFinance/gravv-cli-releases/main/install.sh | bash
```

### Homebrew (macOS/Linux)

```bash
# Add the tap
brew tap GravityFinance/tap https://github.com/GravityFinance/gravv-cli-releases

# Install gravv
brew install gravv
```

### Manual Download

Download the latest release for your platform from the [releases page](https://github.com/GravityFinance/gravv-cli-releases/releases).

| Platform | Architecture | Download |
|----------|--------------|----------|
| macOS | Intel (x86_64) | [gravv_VERSION_darwin_amd64.tar.gz](https://github.com/GravityFinance/gravv-cli-releases/releases/latest) |
| macOS | Apple Silicon (arm64) | [gravv_VERSION_darwin_arm64.tar.gz](https://github.com/GravityFinance/gravv-cli-releases/releases/latest) |
| Linux | x86_64 | [gravv_VERSION_linux_amd64.tar.gz](https://github.com/GravityFinance/gravv-cli-releases/releases/latest) |
| Linux | arm64 | [gravv_VERSION_linux_arm64.tar.gz](https://github.com/GravityFinance/gravv-cli-releases/releases/latest) |
| Windows | x86_64 | [gravv_VERSION_windows_amd64.zip](https://github.com/GravityFinance/gravv-cli-releases/releases/latest) |

### Environment Variables

The install script supports the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `GRAVV_INSTALL_DIR` | Installation directory | `/usr/local/bin` |
| `GRAVV_VERSION` | Specific version to install | `latest` |

Example:
```bash
# Install to a custom directory
GRAVV_INSTALL_DIR=~/.local/bin curl -fsSL https://raw.githubusercontent.com/GravityFinance/gravv-cli-releases/main/install.sh | bash

# Install a specific version
GRAVV_VERSION=1.0.0 curl -fsSL https://raw.githubusercontent.com/GravityFinance/gravv-cli-releases/main/install.sh | bash
```

## Quick Start

After installation:

```bash
# Check the installation
gravv version

# Login with your API keys
gravv login --api-key YOUR_SECRET_KEY --public-key YOUR_PUBLIC_KEY

# Launch the interactive TUI
gravv tui

# Or use CLI commands directly
gravv customers create --first-name John --last-name Doe --email john@example.com
```

## Updating

### Homebrew

```bash
brew upgrade gravv
```

### Script

Re-run the install script to update to the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/GravityFinance/gravv-cli-releases/main/install.sh | bash
```

## Uninstalling

### Homebrew

```bash
brew uninstall gravv
brew untap GravityFinance/tap
```

### Manual

```bash
rm /usr/local/bin/gravv
```

## Shell Completions

After installing, set up shell completions:

```bash
# Bash
gravv completion bash > /etc/bash_completion.d/gravv

# Zsh
gravv completion zsh > "${fpath[1]}/_gravv"

# Fish
gravv completion fish > ~/.config/fish/completions/gravv.fish

# PowerShell
gravv completion powershell > gravv.ps1
```

## Verifying Downloads

All releases include a `checksums.txt` file with SHA256 checksums. Verify your download:

```bash
# Download the checksums file
curl -LO https://github.com/GravityFinance/gravv-cli-releases/releases/latest/download/checksums.txt

# Verify (Linux)
sha256sum -c checksums.txt --ignore-missing

# Verify (macOS)
shasum -a 256 -c checksums.txt --ignore-missing
```

## License

MIT License - see the main [gravv-cli](https://github.com/GravityFinance/gravv-cli) repository for details.
