#!/usr/bin/env bash
set -euo pipefail

# Archived maintenance helper.
#
# This command is safe and sometimes useful, but it does not need to reserve an
# alias in every interactive shell.
#
# Usage:
#   ./archive/cleanup-dsstore.sh [directory]
#
# When no directory is provided, the current directory is cleaned.

target="${1:-.}"

if [ ! -d "$target" ]; then
  printf "'%s' is not a directory.\n" "$target" >&2
  exit 1
fi

find "$target" -name '.DS_Store' -type f -ls -delete
