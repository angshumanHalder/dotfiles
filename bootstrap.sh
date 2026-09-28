#!/bin/bash
# Run from a clone of this repository: bash /path/to/dotfiles/bootstrap.sh
# Authenticate the private git clone separately; no credentials belong here.
set -euo pipefail

if [[ "$(uname -s)" != Darwin || "$EUID" -eq 0 ]]; then
  echo "Run this script on macOS as your normal user, not with sudo." >&2
  exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
[[ -f "$repo_dir/nvim/init.lua" ]] || { echo "Run from the dotfiles checkout." >&2; exit 1; }

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish installing Apple's Command Line Tools, then rerun this script." >&2
  exit 1
fi

brew_bin="$(command -v brew || true)"
if [[ -z "$brew_bin" ]]; then
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then brew_bin="$candidate"; break; fi
  done
fi
if [[ -z "$brew_bin" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  case "$(uname -m)" in
    arm64) brew_bin=/opt/homebrew/bin/brew ;;
    *) brew_bin=/usr/local/bin/brew ;;
  esac
fi
eval "$("$brew_bin" shellenv)"

# No deprecated taps and no persistent Brewfile to overwrite.
brew bundle --file=- <<'BREWFILE'
brew "git"
brew "gh"
brew "neovim"
brew "fzf"
brew "fd"
brew "ripgrep"
brew "lazygit"
brew "tmux"
brew "herdr"
brew "jujutsu"
brew "starship"
brew "stow"
brew "docker"
brew "postgresql@18"
brew "cmake"
brew "pkgconf"
brew "tree-sitter-cli"

# Languages configured in nvim/init.lua. C/C++ use Apple's Clang toolchain.
brew "rustup"
brew "go"
brew "python"
brew "node"
brew "typescript"
brew "lua"

cask "ghostty"
cask "kitty"
cask "orbstack"
cask "obsidian"
cask "raycast"
cask "telegram"
cask "vlc"
cask "font-jetbrains-mono-nerd-font"
BREWFILE

# Homebrew rustup is keg-only and no longer provides rustup-init.
rustup_prefix="$(brew --prefix rustup)"
export PATH="$rustup_prefix/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
rustup toolchain install stable --profile default --component rust-src --component rust-analyzer
rustup default stable

append_once() {
  local file="$1" line="$2"
  touch "$file"
  if ! grep -Fqx -- "$line" "$file"; then printf '\n%s\n' "$line" >> "$file"; fi
}
append_once "$HOME/.zprofile" "eval \"\$(\"$brew_bin\" shellenv)\""
append_once "$HOME/.zprofile" "export PATH=\"$rustup_prefix/bin:\$HOME/.cargo/bin:\$HOME/go/bin:\$PATH\""
append_once "$HOME/.zshrc" 'eval "$(starship init zsh)"'

# The repo is a flat ~/.config tree, not conventional Stow packages.
# Keep a persistent Stow layout of links to tracked files only. Never adopt or
# overwrite existing configs, and never link auth/state directories such as gh.
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
[[ "$config_dir" = /* ]] || { echo "XDG_CONFIG_HOME must be absolute." >&2; exit 1; }
mkdir -p "$config_dir"
if [[ "$(cd "$config_dir" && pwd -P)" != "$repo_dir" ]]; then
  [[ "$config_dir" == "$HOME/.config" ]] || {
    echo "Stow layout targets ~/.config; unset XDG_CONFIG_HOME or use ~/.config." >&2
    exit 1
  }
  stow_dir="$HOME/.local/share/dotfiles-stow"
  while IFS= read -r file; do
    staged="$stow_dir/config/.config/$file"
    mkdir -p "$(dirname "$staged")"
    if [[ -e "$staged" || -L "$staged" ]]; then
      [[ -L "$staged" && "$(readlink "$staged")" == "$repo_dir/$file" ]] || {
        echo "Conflicting Stow source: $staged. Nothing was overwritten." >&2
        exit 1
      }
    else
      ln -s "$repo_dir/$file" "$staged"
    fi
  done < <(git -C "$repo_dir" ls-files -- nvim ghostty kitty herdr)
  stow --dir="$stow_dir" --target="$HOME" --no-folding --simulate config
  stow --dir="$stow_dir" --target="$HOME" --no-folding config
else
  echo "Checkout already is the config directory; no Stow links needed."
fi

brew services start postgresql@18
echo "Bootstrap complete. Open a new terminal to load the updated PATH and prompt."
echo "Open OrbStack once to finish its setup; Docker CLI uses OrbStack's engine."
echo "Open Neovim, restart after first plugin install, then run :Mason."
echo "Install: lua-language-server pyright vtsls gopls dockerfile-language-server yaml-language-server wgsl-analyzer"
echo "Tools: stylua ruff prettierd taplo goimports eslint_d golangci-lint hadolint"
echo "Rust analyzer, rustfmt, and clippy are provided by the stable Rust toolchain."
