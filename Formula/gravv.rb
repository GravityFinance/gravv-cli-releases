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
      sha256 "d3da48b92d1641ee2ce7fd24e655b2d319ecab74b4d030646067e11f242411de"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_darwin_arm64.tar.gz"
      sha256 "6700480a3a8bf311e6fefbfff10b45b4a96dac6e4819662246cd11c2e1fe6088"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_linux_amd64.tar.gz"
      sha256 "c3d5740c48055b8c333561ca43fb710b57d2469fb5df92df33647043ff98240a"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_linux_arm64.tar.gz"
      sha256 "c59c451d5dffe47fac7d968ffad7483c87fd377f501528631a32f233849473e5"
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
