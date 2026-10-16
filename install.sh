#!/usr/bin/env bash
# install.sh — set up a fresh machine from this repo.
#
#   ./install.sh              install packages only
#   ./install.sh --configs    install packages, then deploy config
#
# Run as your normal user; it sudo's only for pacman.

set -uo pipefail

DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="$DOTDIR/packages"

DO_PACKAGES=1
DO_CONFIGS=0
BACKUP=0

for arg in "$@"; do
  case "$arg" in
    --configs)  DO_CONFIGS=1 ;;
    --packages) DO_PACKAGES=1 ;;
    --backup)   BACKUP=1 ;;
    --all)      DO_PACKAGES=1; DO_CONFIGS=1; BACKUP=1 ;;
    -h|--help)  sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
if [ "$DO_PACKAGES" -eq 1 ]; then
  command -v pacman >/dev/null || die "pacman not found — this install path is Arch/CachyOS only"

  log "Installing repo packages (sudo) ..."
  # Comment lines in pacman.txt are stripped so pacman -S - can read it.
  grep -v '^#' "$PKG_DIR/pacman.txt" | grep -v '^[[:space:]]*$' \
    | sudo pacman -S --needed - || warn "some pacman packages failed"

  if [ -s "$PKG_DIR/aur.txt" ]; then
    if command -v paru >/dev/null; then
      log "Installing AUR packages ..."
      grep -v '^#' "$PKG_DIR/aur.txt" | grep -v '^[[:space:]]*$' \
        | paru --needed - || warn "some AUR packages failed"
    elif command -v yay >/dev/null; then
      log "Installing AUR packages (yay) ..."
      grep -v '^#' "$PKG_DIR/aur.txt" | grep -v '^[[:space:]]*$' \
        | yay --needed - || warn "some AUR packages failed"
    else
      warn "no paru/yay — skipping AUR. Install manually:"
      warn "  $(grep -cve '^#' "$PKG_DIR/aur.txt") packages listed in packages/aur.txt"
    fi
  fi

  if [ -s "$PKG_DIR/flatpak.txt" ] && command -v flatpak >/dev/null; then
    log "Installing flatpaks ..."
    flatpak install -y --noninteractive \
      $(grep -v '^#' "$PKG_DIR/flatpak.txt" | grep -v '^[[:space:]]*$') \
      || warn "some flatpaks failed"
  fi

  log "Enabling user services ..."
  systemctl --user enable --now wireplumber pipewire pipewire-pulse 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
if [ "$DO_CONFIGS" -eq 1 ]; then
  STAMP="$(date +%Y%m%d-%H%M%S)"
  BACKUP_DIR="$HOME/.config-backup-$STAMP"

  if [ "$BACKUP" -eq 1 ] && [ -d "$HOME/.config" ]; then
    log "Backing up existing ~/.config -> $BACKUP_DIR"
    cp -a "$HOME/.config" "$BACKUP_DIR"
  fi

  log "Deploying ~/.config ..."
  # rsync --delete would nuke app state on a fresh machine; only overwrite.
  rsync -a "$DOTDIR/config/" "$HOME/.config/"
  # Drop the broken symlink this repo doesn't carry
  rm -f "$HOME/.config/wallust"

  log "Deploying dotfiles ..."
  for f in .bashrc .bash_profile .bash_logout .profile .zshrc .zshenv .gtkrc-2.0; do
    [ -f "$DOTDIR/home/$f" ] && cp -f "$DOTDIR/home/$f" "$HOME/$f"
  done

  log "Installing ~/.local/bin scripts ..."
  mkdir -p "$HOME/.local/bin"
  [ -d "$DOTDIR/home/.local/bin" ] && \
    rsync -a "$DOTDIR/home/.local/bin/" "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

  log "Installing themes, fonts, icons ..."
  mkdir -p "$HOME/.themes" "$HOME/.icons" "$HOME/.local/share/fonts"
  [ -d "$DOTDIR/themes/gtk" ]        && rsync -a "$DOTDIR/themes/gtk/" "$HOME/.themes/"
  [ -d "$DOTDIR/themes/icons" ]      && rsync -a "$DOTDIR/themes/icons/" "$HOME/.icons/"
  [ -d "$DOTDIR/themes/fonts" ]      && rsync -a "$DOTDIR/themes/fonts/" "$HOME/.local/share/fonts/"

  if [ -d "$DOTDIR/themes/gtk/Kvantum" ]; then
    mkdir -p "$HOME/.config/Kvantum"
    rsync -a "$DOTDIR/themes/gtk/Kvantum/" "$HOME/.config/Kvantum/"
  fi
  fc-cache -f >/dev/null 2>&1 && log "Font cache rebuilt"

  log "Installing wallpapers + avatar ..."
  mkdir -p "$HOME/Pictures/Wallpapers"
  [ -d "$DOTDIR/assets/wallpapers" ] && \
    rsync -a "$DOTDIR/assets/wallpapers/" "$HOME/Pictures/Wallpapers/"
  [ -f "$DOTDIR/assets/avatar.jpg" ] && cp -f "$DOTDIR/assets/avatar.jpg" "$HOME/.face"

  log "Installing secret templates (fill these in!) ..."
  mkdir -p "$HOME/.ssh"
  [ -f "$DOTDIR/home/.ssh/config.example" ] && \
    cp -f "$DOTDIR/home/.ssh/config.example" "$HOME/.ssh/config"

  cat <<'EOF'

  Still to do by hand:
    - git identity      cp ~/dots/home/.gitconfig.example ~/.gitconfig  (then edit)
    - ssh key           ssh-keygen -t ed25519    (or copy a backup)
    - external repos    ~/dots/restore-projects.sh --patches
    - editor extension manifests

EOF
fi

echo
log "Done."