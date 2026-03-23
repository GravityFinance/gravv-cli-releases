# typed: false
# frozen_string_literal: true

# This formula is auto-updated from S3 releases.
# Do not edit manually - changes will be overwritten.
class Gravv < Formula
  desc "CLI/TUI tool for the Gravv financial payments platform"
  homepage "https://github.com/GravityFinance/gravv-cli-releases"
  version "0.1.3"
  license "MIT"

  on_macos do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.3/gravv_0.1.3_darwin_amd64.tar.gz"
      sha256 "8759fc46486e9376d62529ced463a78f368664b58e6123c05ef31429260797d2"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.3/gravv_0.1.3_darwin_arm64.tar.gz"
      sha256 "62057cb213c8b315fc6ca65dd4856f3259f9d3726692fec2908004bacf703479"
    end
  end

  on_linux do
    on_intel do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.3/gravv_0.1.3_linux_amd64.tar.gz"
      sha256 "bf35056137561b9925f2c4e6771ff2ef7aad5ee601655edea5b6f87f8d350f06"
    end
    on_arm do
      url "https://gravv-cli.s3.us-east-1.amazonaws.com/releases/v0.1.3/gravv_0.1.3_linux_arm64.tar.gz"
      sha256 "a1c6269eb475729668ab0886108e4098983dfc5a73fcc1eb55958286d4e1726c"
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
