class Lnako < Formula
  desc "Nadesiko 3 v3.7.24 compatible compiler (Zig + LLVM native/AOT)"
  homepage "https://github.com/soramikan/lnako"
  url "https://github.com/soramikan/lnako/archive/refs/tags/v0.2.4.tar.gz"
  version "0.2.4"
  sha256 "898cfd8511f80edf06b4f8323263d8bdf5d1cdc1643ff03225170ce7940fa8e9"
  license "MIT"

  bottle do
    root_url "https://github.com/soramikan/homebrew-tap/releases/download/lnako-0.2.4"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4c668a1178f72f4b8475a6aef5bc407631f151d55ed504306852d38d6a3d0099"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "708434ec5273748fc49f3c2552a18fe31b670d27f293b633f9e45c92e378515c"
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
