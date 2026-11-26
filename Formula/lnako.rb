class Lnako < Formula
  desc "Nadesiko 3 v3.7.24 compatible compiler (Zig + LLVM native/AOT)"
  homepage "https://github.com/soramikan/lnako"
  url "https://github.com/soramikan/lnako/archive/refs/tags/v0.2.6.tar.gz"
  version "0.2.6"
  sha256 "b149d867721cf1e8c0ad0b99f4256d79ed74c08e1cc638d98bdd98fb7bbf18bb"
  license "MIT"

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
