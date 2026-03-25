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
      sha256 "9e7ad232a9874efd39554d0e7ff86bc2e2026ba6192deac845517ac024521ea3"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_darwin_arm64.tar.gz"
      sha256 "eadee120b0e1425ba0c46b9978b5a82fc856b33573e0337ce3e8cd2aca632ea3"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_linux_amd64.tar.gz"
      sha256 "b57ae2eab23fdd6cb1e63ba843b06f37a6b4ce6767bbb3b75ef07643f8ca0ae7"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.9/gravv_0.1.9_linux_arm64.tar.gz"
      sha256 "5e4da4bdbcd2f8e8cc67544f79c99f7a11931d4b0faf22cf6a09bbb88ecea6be"
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
