#!/usr/bin/env bash
# restore-projects.sh — re-clone the external git repos this setup depends on.
#
# Run on a fresh machine AFTER install.sh. See PROJECTS.md for the full list
# and for which repos have local edits that were never pushed.

set -uo pipefail

APPLY_PATCHES=0
[ "${1:-}" = "--patches" ] && APPLY_PATCHES=1

H="$HOME"
mkdir -p "$H/.config"

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# name | url | branch | destination
PROJECTS=(
  "qylock|https://github.com/Darkkal44/qylock.git|main|$H/qylock"
  "ii-material-sddm|https://github.com/ToRvaLDz/ii-material-sddm|dev|$H/ii-material-sddm"
  "matugen-theme-colorful|https://github.com/shreudi/vscode-matugen-theme.git|master|$H/matugen-theme-colorful"
  "matugen-theme-bridge|https://github.com/Grey-007/matugen-theme-bridge|main|$H/matugen-theme-bridge"
  "disktree|https://github.com/tobi/disktree|main|$H/disktree"
  "MacTahoe-icon-theme|https://github.com/vinceliuice/MacTahoe-icon-theme.git|main|$H/MacTahoe-icon-theme"
  "quickshell-git|https://aur.archlinux.org/quickshell-git.git|master|$H/quickshell-git"
  "nvim|https://github.com/LazyVim/starter.git|main|$H/.config/nvim"
  "matugen-themes|https://github.com/InioX/matugen-themes.git|main|$H/.config/matugen/matugen-themes"
)

log "Cloning external projects into $H ..."
for spec in "${PROJECTS[@]}"; do
  IFS='|' read -r name url branch dest <<< "$spec"

  if [ -d "$dest/.git" ]; then
    echo "  = $name (already present, skipping)"
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  if git clone -q --branch "$branch" --single-branch "$url" "$dest" 2>/dev/null; then
    echo "  + $name ($branch)"
  else
    warn "clone failed: $name <- $url"
  fi
done

# ---------------------------------------------------------------------------
# Patches for local edits that were never pushed
# ---------------------------------------------------------------------------
if [ "$APPLY_PATCHES" -eq 1 ]; then
  log "Applying local-edit patches ..."
  PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/patches"

  apply() { # patch-file | target-repo
    [ -f "$1" ] || { warn "missing patch: $(basename "$1")"; return; }
    if git -C "$2" apply "$1" 2>/dev/null; then
      echo "  + applied $(basename "$1")"
    else
      warn "could not apply $(basename "$1") to $2"
    fi
  }

  apply "$PATCH_DIR/qylock-sddm-sh.patch"            "$H/qylock"
  apply "$PATCH_DIR/matugen-theme-colorful.patch"    "$H/matugen-theme-colorful"
  apply "$PATCH_DIR/quickshell-git-PKGBUILD.patch"  "$H/quickshell-git"
  apply "$PATCH_DIR/nvim-config.patch"              "$H/.config/nvim"

  [ -f "$PATCH_DIR/nvim-lazyvim.json" ] && cp -f "$PATCH_DIR/nvim-lazyvim.json" \
    "$H/.config/nvim/lazyvim.json" && echo "  + restored lazyvim.json"

  [ -f "$PATCH_DIR/nvim-transparency.lua" ] && cp -f "$PATCH_DIR/nvim-transparency.lua" \
    "$H/.config/nvim/lua/plugins/transparency.lua" && echo "  + restored transparency.lua"

  if [ -f "$PATCH_DIR/matugen-theme-bridge-package-lock.json" ]; then
    cp -f "$PATCH_DIR/matugen-theme-bridge-package-lock.json" \
      "$H/matugen-theme-bridge/package-lock.json"
    echo "  + restored matugen-theme-bridge/package-lock.json"
  fi
else
  echo
  warn "Local edits NOT restored. Run with --patches to apply them:"
  warn "  ./restore-projects.sh --patches"
  warn "See PROJECTS.md for what they are."
fi

echo
log "Done."