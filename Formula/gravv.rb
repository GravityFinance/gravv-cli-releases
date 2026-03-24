# typed: false
# frozen_string_literal: true

# This formula is auto-updated from S3 releases.
# Do not edit manually - changes will be overwritten.
class Gravv < Formula
  desc "CLI/TUI tool for the Gravv financial payments platform"
  homepage "https://github.com/GravityFinance/gravv-cli-releases"
  version "0.1.5"
  license "MIT"

  on_macos do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.5/gravv_0.1.5_darwin_amd64.tar.gz"
      sha256 "1aed932853cdc592a16a006d0d1be19c3c593e0516615082ab0c187e85c68cc3"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.5/gravv_0.1.5_darwin_arm64.tar.gz"
      sha256 "5b72d77a057a836496430eb6a5dcde87299abb582b2a6083b06b7ba0df771b22"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.5/gravv_0.1.5_linux_amd64.tar.gz"
      sha256 "d05975a9d91a96833e717b45210ad0029f3f0efc650a2554c78aa04c62cb5d8d"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.5/gravv_0.1.5_linux_arm64.tar.gz"
      sha256 "136851a911c0a8a31b9c3e7437cd0b2eeeec989b1e2d9db09257289010e00e76"
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
