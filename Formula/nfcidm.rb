class Nfcidm < Formula
  desc "Read a FeliCa IDm with native macOS USB and PC/SC APIs"
  homepage "https://github.com/takesako/nfcidm"
  url "https://github.com/takesako/nfcidm/archive/refs/tags/v0.5.4.tar.gz"
  sha256 "1d02b28f573628256e5ff3ba57c075a2d5559c2a490f56889a8d89b9aa39d792"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  def install
    system "make", "CC=#{ENV.cc}", "test"
    system "make", "CC=#{ENV.cc}"
    bin.install "nfcidm"
  end

  test do
    assert_equal "nfcidm #{version}\n", shell_output("#{bin}/nfcidm --version")
    assert_match "Usage: nfcidm", shell_output("#{bin}/nfcidm --help")
  end
end
