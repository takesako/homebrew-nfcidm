class Nfcidm < Formula
  desc "Read a FeliCa IDm with native macOS USB and PC/SC APIs"
  homepage "https://github.com/takesako/nfcidm"
  url "https://github.com/takesako/nfcidm/archive/refs/tags/v0.5.5.tar.gz"
  sha256 "f4d1298b8a03bc56a4c69847a8f89300721ff26ed753f3da1e82ce22f509778f"
  license "MIT"

  bottle do
    root_url "https://github.com/takesako/homebrew-nfcidm/releases/download/nfcidm-0.5.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c5176a7a1244baac8dd27843ac56c68b1e9c7f838b07cfaf6c5d48f274abbc32"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ee3320f79466541141ef76305e1b617caa68aead0ccbee593bf41294ab506107"
  end

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
