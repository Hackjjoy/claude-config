#!/usr/bin/env bash
# Locate the "Daniel 2nd Brain" Obsidian / Google Drive vault across macOS and
# Windows (Git Bash). Prints the absolute vault path to stdout on success.
# On failure, prints what it tried to stderr and exits 1.
#
# Override detection entirely by exporting SECOND_BRAIN_VAULT=/path/to/vault.
#
# Used by the global skills that touch the vault (second-brain, morning-briefing)
# so the path logic lives in exactly one place.

set -u

VAULT_SUFFIX="Vaults/Daniel 2nd Brain"
tried=""

emit() { printf '%s\n' "$1"; exit 0; }

check() { # $1 = candidate vault path
  tried="$tried
  $1"
  [ -d "$1" ] && emit "$1"
}

# 1. Explicit override wins.
if [ -n "${SECOND_BRAIN_VAULT:-}" ]; then
  if [ -d "$SECOND_BRAIN_VAULT" ]; then
    emit "$SECOND_BRAIN_VAULT"
  fi
  printf 'second-brain: SECOND_BRAIN_VAULT is set but is not a directory: %s\n' "$SECOND_BRAIN_VAULT" >&2
  exit 1
fi

# 2. Known Windows mount — the vault's usual home on this machine (G: drive).
#    Checked first as a fast path; harmless on macOS (the directory won't exist).
check "/g/My Drive/$VAULT_SUFFIX"

# 3. macOS — Google Drive for Desktop mounts under CloudStorage.
for base in "$HOME/Library/CloudStorage"/GoogleDrive-*/"My Drive"; do
  [ -d "$base" ] && check "$base/$VAULT_SUFFIX"
done

# 4. Windows Git Bash — Google Drive for Desktop mounts as a drive letter.
#    Letters are virtual mounts and do not enumerate via globbing, so probe a
#    likely set explicitly (Google Drive defaults to G:, but the letter varies).
for d in h i j k l m n o p q r s t u v w x y z d e f; do
  check "/$d/My Drive/$VAULT_SUFFIX"
done

# 5. Other plausible layouts (Drive mounted into the home folder).
check "$HOME/My Drive/$VAULT_SUFFIX"
check "$HOME/Google Drive/$VAULT_SUFFIX"

printf 'second-brain: could not locate the vault. Tried:%s\n' "$tried" >&2
printf 'Set SECOND_BRAIN_VAULT to the vault path to override.\n' >&2
exit 1
