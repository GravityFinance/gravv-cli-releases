# typed: false
# frozen_string_literal: true

# This formula is auto-updated from S3 releases.
# Do not edit manually - changes will be overwritten.
class Gravv < Formula
  desc "CLI/TUI tool for the Gravv financial payments platform"
  homepage "https://github.com/GravityFinance/gravv-cli-releases"
  version "0.1.9"
  license "MIT"

  on_macos do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_darwin_amd64.tar.gz"
      sha256 "2841f990333197b7ed56a4f0b4efd974f4fa55fd9233237fa50feb01564836bd"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_darwin_arm64.tar.gz"
      sha256 "527f6f2769160db5de0cd40a712bb908be5ef5d6d82f7f7d4e037f360bf4ea8c"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_linux_amd64.tar.gz"
      sha256 "b71945485aae18a5e231565e0abd89677a839b5ac572b93cb0a583e57b512d91"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_linux_arm64.tar.gz"
      sha256 "c790e831f0bc40191846ad081b5788b965dd27c9311d3f862e69f336c3037c75"
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
