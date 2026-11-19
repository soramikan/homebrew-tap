class Lnako < Formula
  desc "Nadesiko 3 v3.7.24 compatible compiler (Zig + LLVM native/AOT)"
  homepage "https://github.com/soramikan/lnako"
  url "https://github.com/soramikan/lnako/archive/refs/tags/v0.2.5.tar.gz"
  version "0.2.5"
  sha256 "e78605dc3bf15e18a3c1c10ea00044e3345f77fe6fb2c7a9e11961d53fee1d7a"
  license "MIT"

  bottle do
    root_url "https://github.com/soramikan/homebrew-tap/releases/download/lnako-0.2.5"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d8c3bd390f7c035d624834704a1742ebc7c68dd7667f94e6a41e27c5b47fc5a1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "85da6e31baa4afb191b1e312838c6ad0812e349391c9fdcb84485bfba435c1de"
  end

  depends_on "zig" => :build

  # QuickJS is statically linked for `--compat-js` mode only.
  resource "quickjs" do
    url "https://bellard.org/quickjs/quickjs-2026-06-04.tar.xz"
    sha256 "b376e839b322978313d929fd20663b11ba58b75df5a46c126dd19ea2fa70ad2a"
  end

  def install
    resource("quickjs").stage buildpath/"quickjs"

    system "zig", "build",
           "-Doptimize=ReleaseSafe",
           "-Dcompat-js=true",
           "-Dquickjs-dir=#{buildpath}/quickjs"

    bin.install "zig-out/bin/lnako"
    lib.install "zig-out/lib/liblnako_runtime.a"
  end

  def caveats
    <<~EOS
      `lnako build` (AOT) requires the pinned LLVM/LLD toolchain.
      Install it with:
        lnako toolchain install
      or point to an existing LLVM with LNAKO_LLVM_DIR.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lnako --version")

    (testpath/"hello.nako3").write "「こんにちは」と表示する。\n"
    output = shell_output("#{bin}/lnako run #{testpath}/hello.nako3")
    assert_match "こんにちは", output
  end
end
