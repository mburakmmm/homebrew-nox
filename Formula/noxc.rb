# Homebrew formülü şablonu: `scripts/update_homebrew_formula.py` sürüm ve sha256 yer tutucularını bir GitHub Release'ten doldurur,
# sonucu `mburakmmm/homebrew-nox` deposuna `Formula/noxc.rb` olarak koyar (bkz. docs/install/index.md, spec §3.340).
class Noxc < Formula
  desc "Compiler and project tool for the Nox programming language"
  homepage "https://noxlang.com"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.0.179/nox-lang-v2.0.179-macos-arm64.tar.gz"
      sha256 "f723ee6d716c9530e191a35b17a1ade913d45276d492feace2aadbaa46af0820"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.0.179/nox-lang-v2.0.179-linux-arm64.tar.gz"
      sha256 "62bcb3950ffb93c0dc82d3409be59b7d7424a0d80d8560439a65f39bbf12a018"
    end
    on_intel do
      url "https://github.com/mburakmmm/nox-lang/releases/download/v2.0.179/nox-lang-v2.0.179-linux-x64.tar.gz"
      sha256 "f76f2ae6ff25e8df414072d2c03394eb653dfa541354190fa615c1f71455105c"
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
