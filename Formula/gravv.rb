# typed: false
# frozen_string_literal: true

# This formula is auto-updated from S3 releases.
# Do not edit manually - changes will be overwritten.
class Gravv < Formula
  desc "CLI/TUI tool for the Gravv financial payments platform"
  homepage "https://github.com/GravityFinance/gravv-cli-releases"
  version "0.1.7"
  license "MIT"

  on_macos do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.7/gravv_0.1.7_darwin_amd64.tar.gz"
      sha256 "74a4c6872d9cd684dc24d7242bff808193cf071c9ef95b85bdfc2071ac1405e8"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.7/gravv_0.1.7_darwin_arm64.tar.gz"
      sha256 "0dbdc163bd26cf3144ed5246d18b71f081ab10db0da38b2563b8ed19dad73611"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.7/gravv_0.1.7_linux_amd64.tar.gz"
      sha256 "128a4ae353c4796643cc30d65c3d3dc96d3facf311b60dd3a908913327c45aff"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.7/gravv_0.1.7_linux_arm64.tar.gz"
      sha256 "c4a915fbde786e08f965c56a6f6318c995cf0162fcd26c35e1abc12397ee707b"
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
