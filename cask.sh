#!/usr/bin/env bash
set -euo pipefail

# Compatibility wrapper for `./cask.sh`.
#
# GUI applications are now declared in Brewfile using Homebrew's supported app
# syntax. This wrapper delegates to Brewfile so there is a single application
# inventory.

cd "$(dirname "$0")"

if ! command -v brew >/dev/null 2>&1; then
  printf 'Homebrew is not installed or is not on PATH.\n' >&2
  printf 'Install Homebrew first, then rerun this script.\n' >&2
  exit 1
fi

brew bundle --file ./Brewfile
