class Nfcidm < Formula
  desc "Read a FeliCa IDm with native macOS USB and PC/SC APIs"
  homepage "https://github.com/takesako/nfcidm"
  url "https://github.com/takesako/nfcidm/archive/refs/tags/v0.5.5.tar.gz"
  sha256 "f4d1298b8a03bc56a4c69847a8f89300721ff26ed753f3da1e82ce22f509778f"
  license "MIT"

  bottle do
    root_url "https://github.com/takesako/homebrew-nfcidm/releases/download/nfcidm-0.5.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fe8a9c46202eb3d7587451be7e45e8d69de5e6d1aaf0624eee131baa27ae4153"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "821ce3f02637f85494806b8267914ee3995b15d48b5557b770196ef842228bac"
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
