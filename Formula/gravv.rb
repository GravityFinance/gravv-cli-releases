# typed: false
# frozen_string_literal: true

# This formula is auto-updated from S3 releases.
# Do not edit manually - changes will be overwritten.
class Gravv < Formula
  desc "CLI/TUI tool for the Gravv financial payments platform"
  homepage "https://github.com/GravityFinance/gravv-cli-releases"
  version "0.1.6"
  license "MIT"

  on_macos do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.6/gravv_0.1.6_darwin_amd64.tar.gz"
      sha256 "09ce00eefaee100e1c1c7db52f212f45a61a93e3213b0af6902389abacd78d70"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.6/gravv_0.1.6_darwin_arm64.tar.gz"
      sha256 "4251ee12a1f25aca3af5d7814dec9943d4af367f144f88f1cb71e1881977ed6e"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.6/gravv_0.1.6_linux_amd64.tar.gz"
      sha256 "f035387eadb158b8be8f1032f0d13384ddb309e6f8d7cf4551a131e0eedc70bd"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.6/gravv_0.1.6_linux_arm64.tar.gz"
      sha256 "6db0504b80c43cbb1d2cb4ae6d40299ac8a68e64e3343a9f570d1cc0558e34ff"
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
