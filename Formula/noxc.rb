# Homebrew formülü şablonu: `scripts/update_homebrew_formula.py` sürüm ve sha256 yer tutucularını bir GitHub Release'ten doldurur,
# sonucu `mburakmmm/homebrew-nox` deposuna `Formula/noxc.rb` olarak koyar (bkz. docs/install/index.md, spec §3.340).
class Noxc < Formula
  desc "Compiler and project tool for the Nox programming language"
  homepage "https://noxlang.com"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.2.15/nox-lang-v2.2.15-macos-arm64.tar.gz"
      sha256 "84a4cae25a2d327682686e527948f86e5f27e5b3a1a293e5154d68789996c9ad"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.2.15/nox-lang-v2.2.15-linux-arm64.tar.gz"
      sha256 "c9e54307893b52d4889e1e8064e56ed37c9771f1918bf9454c659dc92559a8a0"
    end
    on_intel do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.2.15/nox-lang-v2.2.15-linux-x64.tar.gz"
      sha256 "8f2e1cdf21210c4f7379e8abd2540a1e7851830a9b2c26a54db2fa541fe213a5"
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
