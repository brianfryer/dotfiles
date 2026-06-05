#!/usr/bin/env bash
set -euo pipefail

# Fresh-machine bootstrap for this dotfiles repo.
#
# Responsibilities:
#   1. Install Xcode Command Line Tools when needed.
#   2. Install Homebrew when needed.
#   3. Install packages and applications from Brewfile.
#   4. Link dotfiles with symlink-setup.sh.
#   5. Leave secrets, cloud SDKs, and project-specific runtimes to ~/.extra or
#      mise-managed project config.

repo_root="$(cd "$(dirname "$0")" && pwd)"

log() {
  printf '\n==> %s\n' "$*"
}

install_xcode_command_line_tools() {
  if xcode-select --print-path >/dev/null 2>&1; then
    log "Xcode Command Line Tools already installed"
    return 0
  fi

  log "Requesting Xcode Command Line Tools install"
  xcode-select --install >/dev/null 2>&1 || true

  until xcode-select --print-path >/dev/null 2>&1; do
    sleep 5
  done
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed"
    return 0
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

capture_current_machine_inventory() {
  local migration_dir="$HOME/migration"

  log "Capturing current machine inventory in $migration_dir"
  mkdir -p "$migration_dir/home"

  if command -v brew >/dev/null 2>&1; then
    brew list --formula > "$migration_dir/brew-formulae.txt"
    brew list --cask > "$migration_dir/brew-casks.txt" || true
  fi

  [ -f "$HOME/.extra" ] && cp "$HOME/.extra" "$migration_dir/home/.extra"
  [ -f "$HOME/.z" ] && cp "$HOME/.z" "$migration_dir/home/.z"
  [ -f "$HOME/.gitconfig.local" ] && cp "$HOME/.gitconfig.local" "$migration_dir/home/.gitconfig.local"
}

install_packages() {
  log "Installing Brewfile"
  brew bundle --file "$repo_root/Brewfile"
}

link_dotfiles() {
  log "Linking dotfiles"
  "$repo_root/symlink-setup.sh"
}

main() {
  install_xcode_command_line_tools
  install_homebrew
  capture_current_machine_inventory
  install_packages
  link_dotfiles

  log "Bootstrap complete. Open a new shell to load the refreshed dotfiles."
}

main "$@"
