#!/usr/bin/env bash
set -euo pipefail

# Link this repo's selected dotfiles into $HOME.
#
# The target list is explicit on purpose. Auto-discovering every dotfile in the
# repo makes backups, examples, Git metadata, generated files, and retired
# experiments too easy to link into a real home directory.
#
# Usage:
#   ./symlink-setup.sh
#   ./symlink-setup.sh --dry-run

dry_run=false

case "${1:-}" in
  --dry-run)
    dry_run=true
    ;;
  "")
    ;;
  *)
    printf 'Usage: %s [--dry-run]\n' "$0" >&2
    exit 2
    ;;
esac

repo_root="$(cd "$(dirname "$0")" && pwd)"

items_to_link=(
  ".aliases"
  ".bash_profile"
  ".bash_prompt"
  ".bashrc"
  ".exports"
  ".functions"
  ".gitconfig"
  ".gitignore"
  ".inputrc"
  ".zprofile"
  ".zshrc"
)

info() {
  printf '  [info] %s\n' "$*"
}

success() {
  printf '  [ok] %s\n' "$*"
}

warn() {
  printf '  [warn] %s\n' "$*" >&2
}

confirm() {
  local prompt="$1"
  local reply

  printf '%s (y/n) ' "$prompt" >&2
  read -r reply
  case "$reply" in
    [Yy]) return 0 ;;
    *) return 1 ;;
  esac
}

link_item() {
  local item="$1"
  local source_path="$repo_root/$item"
  local target_path="$HOME/$(basename "$item")"

  if [ ! -e "$source_path" ]; then
    warn "Skipping missing source: $source_path"
    return 0
  fi

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    success "$target_path already links to $source_path"
    return 0
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    if [ "$dry_run" = true ]; then
      info "Would ask before replacing $target_path with a symlink to $source_path"
      return 0
    fi

    if ! confirm "$target_path exists. Replace it with a symlink to $source_path?"; then
      warn "Skipped $target_path"
      return 0
    fi

    rm -rf "$target_path"
  fi

  if [ "$dry_run" = true ]; then
    info "Would link $target_path -> $source_path"
  else
    ln -s "$source_path" "$target_path"
    success "$target_path -> $source_path"
  fi
}

for item in "${items_to_link[@]}"; do
  link_item "$item"
done
