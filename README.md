# gravv-cli-releases

Public distribution for [gravv-cli](https://github.com/GravityFinance/gravv-cli), the CLI/TUI for the Gravv payments platform.

This repository holds the install script, the Homebrew formula, and the workflows that keep both pointing at the published release artifacts.

## Install

```bash
curl -sSL https://get.gravv.xyz | sh
```

That URL is a Cloudflare Worker serving [`install.sh`](install.sh) from this repository. The script is POSIX `sh`, so piping it into `sh` (not just `bash`) works.

If you would rather not pipe a script into a shell, read it first:

```bash
curl -sSL https://get.gravv.xyz -o install.sh
less install.sh
sh install.sh
```

### Homebrew

```bash
brew tap GravityFinance/tap https://github.com/GravityFinance/gravv-cli-releases
brew install gravv
```

The explicit URL is needed because this repository is not named `homebrew-tap`. To drop it, mirror `Formula/` into a repository called `homebrew-tap` and `brew tap GravityFinance/tap` will resolve on its own.

### Manual

Artifacts are published per version:

```
https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v<VERSION>/gravv_<VERSION>_<os>_<arch>.tar.gz
https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v<VERSION>/checksums.txt
```

`<os>` is `darwin`, `linux` or `windows`; `<arch>` is `amd64` or `arm64`. Windows ships as `.zip`. The current version is at `releases/latest/version.txt`.

## Install script options

| Variable | Description | Default |
|---|---|---|
| `GRAVV_VERSION` | Version to install, with or without a leading `v` | latest |
| `GRAVV_INSTALL_DIR` | Where to put the binary | `/usr/local/bin`, falling back to `~/.local/bin` |
| `GRAVV_BASE_URL` | Artifact host, for mirrors and testing | S3 bucket above |
| `GRAVV_NO_SUDO` | Set to `1` to never escalate; installs under `$HOME` | unset |
| `GRAVV_SKIP_VERIFY` | Set to `1` to skip checksum verification | unset |
| `NO_COLOR` | Set to anything to disable coloured output | unset |

```bash
# Install somewhere on your own PATH, no sudo
curl -sSL https://get.gravv.xyz | GRAVV_INSTALL_DIR="$HOME/.local/bin" sh

# Pin a version
curl -sSL https://get.gravv.xyz | GRAVV_VERSION=0.1.9 sh
```

The script verifies the SHA256 of the download against the published `checksums.txt` and **refuses to install** if it does not match, if no checksum is published for the platform, or if no hashing tool is available. `GRAVV_SKIP_VERIFY=1` overrides that; there is no good reason to use it outside local testing.

## Quick start

```bash
gravv version
gravv login                 # authenticate with your API key
gravv tui                   # interactive terminal UI
gravv --help                # every command
```

Sandbox and production are selected by **which API key you log in with**, not by a different host — the key carries its own environment claim.

## Updating and uninstalling

```bash
brew upgrade gravv                       # Homebrew
curl -sSL https://get.gravv.xyz | sh     # script: re-run to update

brew uninstall gravv && brew untap GravityFinance/tap
rm /usr/local/bin/gravv                  # or wherever you installed it
```

## Shell completions

The Homebrew formula installs completions automatically. With the script:

```bash
gravv completion bash > /etc/bash_completion.d/gravv
gravv completion zsh  > "${fpath[1]}/_gravv"
gravv completion fish > ~/.config/fish/completions/gravv.fish
```

## Maintaining this repository

### The formula

`Formula/gravv.rb` is generated, not hand-edited:

```bash
./scripts/update-formula.sh          # track the current release
./scripts/update-formula.sh 0.2.0    # pin a version
```

`update-formula.yml` runs it every four hours, on demand, and on a `gravv-released` `repository_dispatch` from the release pipeline. It regenerates the formula unconditionally and commits only when the file changes, so a wrong hash is repaired on the next run rather than waiting for a version bump.

### Verification

`verify.yml` runs on every push and nightly:

- `install.sh` parses under `dash`, `bash` and `busybox ash`, passes `shellcheck -s sh`, and contains no bash-only constructs.
- Every hash in the formula is checked against the artifact it points at.
- The script is piped into `sh` on Linux and macOS, x86_64 and arm64, and the installed binary must run.
- A tampered checksum must be refused and must leave nothing installed.
- `brew install` is run against the formula on both macOS architectures.

Both install paths have broken silently before — `install.sh` pointed at a releases API that returned 404, and three of the four formula hashes matched no artifact, so `brew install` failed everywhere except Apple Silicon. These checks exist so that cannot recur unnoticed.

## License

MIT. See the [gravv-cli](https://github.com/GravityFinance/gravv-cli) repository.
