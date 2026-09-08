class Lnako < Formula
  desc "Nadesiko 3 v3.7.24 compatible compiler (Zig + LLVM native/AOT)"
  homepage "https://github.com/soramikan/lnako"
  url "https://github.com/soramikan/lnako/archive/af137cf299b01a318cb84339b6f9097be01e372e.tar.gz"
  version "0.1.0"
  sha256 "02f309dcc8a7058faabda06331c74ffcdf1bb46b0efe46ac4e3d86c85eac5139"
  license "MIT"

  bottle do
    root_url "https://github.com/soramikan/homebrew-tap/releases/download/lnako-0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a060a29dc550f5b07f0785aac4ca54452e5c9ad80a100d4d0233acd55bf1195a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "abac85728c2340bc45fd4c0c40c4fb043e152ae2381e48f100f5e1b0e9a75198"
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
