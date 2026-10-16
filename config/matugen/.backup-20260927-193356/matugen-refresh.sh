#!/bin/sh
# Re-render all matugen templates after a wallpaper source changes.
# Triggered by matugen-refresh.path (Ukishima state or current_wallpaper.jpg).
# Videos can't be read by matugen, so fall back to Ukishima's still frame.
set -eu
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/ukishima-wallpaper"
CURRENT="$HOME/Pictures/Wallpapers/current_wallpaper.jpg"
STILL="${XDG_STATE_HOME:-$HOME/.local/state}/ukishima-wallpaper-still.png"
pic="$(cat "$STATE" 2>/dev/null || true)"
# Ukishima normally owns the state file. Also support manually replacing
# current_wallpaper.jpg, which is useful when changing wallpapers outside it.
if [ -f "$CURRENT" ]; then
  if [ ! -f "$STATE" ] || [ "$CURRENT" -nt "$STATE" ]; then
    pic="$CURRENT"
  fi
fi
case "$pic" in
  *.mp4|*.webm|*.mkv|*.mov|*.gif) pic="$STILL" ;;
esac
[ -n "$pic" ] && [ -f "$pic" ] || exit 0
# scheme-vibrant: TokyoNight-grade saturation while still following the
# wallpaper. (Default tonal-spot renders muted/pastel on most wallpapers.)
# NOTE: mirror this flag on manual runs: matugen image <pic> -m dark -t scheme-vibrant
matugen image "$pic" -m dark -t scheme-vibrant
# Push the regenerated theme into every running kitty. The include file alone
# is not enough: kitty only auto-reloads kitty.conf itself, never includes.
# Best-effort: silently skips when no kitty (with this socket) is running.
THEME="$HOME/.config/kitty/themes/Matugen.conf"
if [ -f "$THEME" ]; then
  kitty @ --to unix:/tmp/kitty.sock set-colors "$THEME" >/dev/null 2>&1 || true
fi
