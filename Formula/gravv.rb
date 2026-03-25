# typed: false
# frozen_string_literal: true

# This formula is auto-updated from S3 releases.
# Do not edit manually - changes will be overwritten.
class Gravv < Formula
  desc "CLI/TUI tool for the Gravv financial payments platform"
  homepage "https://github.com/GravityFinance/gravv-cli-releases"
  version "0.1.8"
  license "MIT"

  on_macos do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.8/gravv_0.1.8_darwin_amd64.tar.gz"
      sha256 "6127f1b870e0f201b64c08ad20fc87f4df1e4339b4b2669a2e86bd684dba7fb1"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.8/gravv_0.1.8_darwin_arm64.tar.gz"
      sha256 "5b11c178a0ccd3a2eeb7072abceb40581b061a4fb2539ecdb5e7dcff4ac563a7"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.8/gravv_0.1.8_linux_amd64.tar.gz"
      sha256 "928a1cbba224ffcf0f024fdf06ea3dfd8ebc6a06b9b59efa2976dcc06d65bea1"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.8/gravv_0.1.8_linux_arm64.tar.gz"
      sha256 "b041a55f575a40e2b7ab5b45140f660e093a864c535130e0fa927b9f6801f510"
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
