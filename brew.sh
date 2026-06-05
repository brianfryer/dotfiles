#!/usr/bin/env bash
set -euo pipefail

# Compatibility wrapper for `./brew.sh`.
#
# The package inventory now lives in Brewfile so Homebrew can resolve formulae,
# casks, taps, and cleanup behavior through one supported interface. Keeping
# this wrapper lets older notes and muscle memory keep working while avoiding a
# second, drifting list of packages.

cd "$(dirname "$0")"

if ! command -v brew >/dev/null 2>&1; then
  printf 'Homebrew is not installed or is not on PATH.\n' >&2
  printf 'Install Homebrew first, then rerun this script.\n' >&2
  exit 1
fi

brew update
brew bundle --file ./Brewfile
brew cleanup
