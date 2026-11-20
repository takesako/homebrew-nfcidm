class Nfcidm < Formula
  desc "Read a FeliCa IDm with native macOS USB and PC/SC APIs"
  homepage "https://github.com/takesako/nfcidm"
  url "https://github.com/takesako/nfcidm/releases/download/v0.5.2/nfcidm-0.5.2.tar.gz"
  sha256 "68b3eb3653a7a9bcb209046973196e7c2cea9223d92868a29399b7f30ef571ca"
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
