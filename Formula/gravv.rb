# typed: false
# frozen_string_literal: true

# This formula is auto-updated from S3 releases.
# Do not edit manually - changes will be overwritten.
class Gravv < Formula
  desc "CLI/TUI tool for the Gravv financial payments platform"
  homepage "https://github.com/GravityFinance/gravv-cli-releases"
  version "0.1.4"
  license "MIT"

  on_macos do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.4/gravv_0.1.4_darwin_amd64.tar.gz"
      sha256 "073fc156f4f2089762ec95fd674907001b0acc47bad26199448d824bb06c74c2"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.4/gravv_0.1.4_darwin_arm64.tar.gz"
      sha256 "1928419379233131f2e2f0303b034d0861a861d7c91c65801d3e53bba37876c6"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.4/gravv_0.1.4_linux_amd64.tar.gz"
      sha256 "8d9d05e4eb696afd9d986bdd14d85fadf3eb5b8d12b983a5b973f48cadafd71d"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.4/gravv_0.1.4_linux_arm64.tar.gz"
      sha256 "764564054268469c8a173ba8e1dbc4a57e41e9d1cb4d1ec26f2bb9348ff851d4"
    end
  end

  def install
    bin.install "gravv"
    generate_completions_from_executable(bin/"gravv", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gravv version")
  end
end
