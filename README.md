# homebrew-nox

[Homebrew](https://brew.sh) tap for [Nox](https://noxlang.com), a statically typed language with Python-like syntax that compiles to native code.

```sh
brew tap mburakmmm/nox
brew install noxc
```

or in one step: `brew install mburakmmm/nox/noxc`.

`noxc` is the compiler and project tool; the formula also installs `noxlsp` (the language server). The bundled `qbe` back end is found automatically, so you do not need to install it separately.
To compile programs you need a C toolchain (Xcode Command Line Tools on macOS, `gcc` or `clang` on Linux).

| Platform | |
|---|---|
| macOS, Apple Silicon | supported |
| Linux x86-64 and arm64 | supported (Homebrew on Linux) |
| macOS, Intel | not available: releases are not built for it (use the [install script](https://noxlang.com/docs/install/) or build from source) |

Update with `brew upgrade noxc` (not `noxc upgrade`, which would fight Homebrew over the files).

The formula is generated from each [Nox release](https://github.com/mburakmmm/nox-lang/releases) by `scripts/update_homebrew_formula.py` in the main repository; do not edit `Formula/noxc.rb` by hand.
