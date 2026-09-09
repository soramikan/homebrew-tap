class Lnako < Formula
  desc "Nadesiko 3 v3.7.24 compatible compiler (Zig + LLVM native/AOT)"
  homepage "https://github.com/soramikan/lnako"
  url "https://github.com/soramikan/lnako/archive/refs/tags/v0.1.1.tar.gz"
  version "0.1.1"
  sha256 "5969cc04bc76521b8480b270bfdcd7e4e2d8af0a74ea3e80e3b48003feea3923"
  license "MIT"

  bottle do
    root_url "https://github.com/soramikan/homebrew-tap/releases/download/lnako-0.1.1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "97521eee442a61c76ef7f70e2bed8b38ccc91c08611317e71a85f305f3fbc9e9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "414adbc26ce1c80c7058cb6e549bece9e5caa5d6c0a3e6cb016291eb415470c5"
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
