# homebrew-tap

soramikan 製ソフトウェアの Homebrew tap です。

## 使い方

```sh
brew tap soramikan/tap
brew install lnako
```

bottle（ビルド済みバイナリ）が利用可能な環境ではbottleが優先され、
それ以外ではソースからビルドされます（Zigが必要です）。

## Formulae

| Formula | 説明 |
| --- | --- |
| `lnako` | なでしこ3 v3.7.24互換のZig+LLVMネイティブコンパイラ |

### lnako について

- インストール直後は `lnako run`（Interpreter）がそのまま使えます。
- `lnako build`（AOTネイティブコンパイル）にはpin済みLLVM/LLD toolchainが必要です。
  `lnako toolchain install` で導入するか、`LNAKO_LLVM_DIR` で既存LLVMを指定してください。
- QuickJSは`--compat-js`モード用に静的リンク済みです（通常実行には使われません）。
- Upstream: <https://github.com/soramikan/lnako>

## Bottleビルド

Bottleは `.github/workflows/bottle.yml`（手動dispatch）でビルドし、
このリポジトリのReleaseへuploadして`bottle do`ブロックを更新します。
