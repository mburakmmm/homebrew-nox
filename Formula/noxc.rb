# Homebrew formülü şablonu: `scripts/update_homebrew_formula.py` sürüm ve sha256 yer tutucularını bir GitHub Release'ten doldurur,
# sonucu `mburakmmm/homebrew-nox` deposuna `Formula/noxc.rb` olarak koyar (bkz. docs/install/index.md, spec §3.340).
class Noxc < Formula
  desc "Compiler and project tool for the Nox programming language"
  homepage "https://noxlang.com"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.2.103/nox-lang-v2.2.103-macos-arm64.tar.gz"
      sha256 "2b563be1f02a67e52645a4cb2c71426fa666e45773c7d3e7dc03e4e3b047a662"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.2.103/nox-lang-v2.2.103-linux-arm64.tar.gz"
      sha256 "4d56b9335a5cf0315783dae73a7e6ac85febb137b807c84fcabe7835a5afe556"
    end
    on_intel do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.2.103/nox-lang-v2.2.103-linux-x64.tar.gz"
      sha256 "d827f342ee64632b2523ef6ce944c3abfd9362efc6094f59aa0f61897e3588d6"
    end
  end

  # Release arşivi yalnızca Apple Silicon macOS ile Linux (x86-64, arm64) için üretilir.
  depends_on arch: :arm64 if OS.mac?

  def install
    # Arşivin düzeni `noxc`nin kendi kurulum düzenidir: `<kök>/bin`, `<kök>/lib` (runtime nesneleri + stdlib), `<kök>/include`.
    # Kaynakları ikilinin yanında bulabilmesi için ağaç olduğu gibi libexec'e konur; `noxc` ve `noxlsp` ise `libexec/bin`i PATH'e
    # ekleyen birer sarmalayıcıdır (arşivle gelen `qbe` böylece `noxc`nin çıplak `qbe` aramasında bulunur, ayrı bir `qbe` kurmak gerekmez).
    libexec.install "bin", "lib", "include"
    %w[noxc noxlsp].each do |tool|
      (bin/tool).write_env_script libexec/"bin"/tool, PATH: "#{libexec}/bin:${PATH}"
    end
    doc.install "README.md", "CHANGELOG.md"
  end

  def caveats
    <<~EOS
      noxc derlenen programları bağlamak için bir C araç zincirine ihtiyaç duyar (macOS'ta Xcode Command Line Tools,
      Linux'ta gcc/clang). Kendini güncellemek için `noxc upgrade` yerine `brew upgrade noxc` kullanın.
    EOS
  end

  test do
    (testpath/"hello.nox").write <<~NOX
      print("merhaba brew")
    NOX
    assert_match "merhaba brew", shell_output("#{bin}/noxc run hello.nox")
    assert_match version.to_s, shell_output("#{bin}/noxc version 2>&1")
  end
end
