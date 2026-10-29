#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
MODDIR="${EU4_USER_DIR:-$HOME/.local/share/Paradox Interactive/Europa Universalis IV}/mod"
mkdir -p "$MODDIR"
{
  grep -v -e '^remote_file_id=' -e '^name=' -e '^path=' "$REPO/descriptor.mod"
  echo 'name="Vault Rat Fork (dev)"'
  echo "path=\"$REPO\""
} > "$MODDIR/vault_rat_fork_dev.mod"
echo "Wrote $MODDIR/vault_rat_fork_dev.mod -> $REPO"
