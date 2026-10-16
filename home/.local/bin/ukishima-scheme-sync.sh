#!/bin/sh
# Sync ~/.config/hypr/scheme/current.lua from Ukishima's matugen palette.
# Only keys actually read by the hypr config (+ base M3 structure) are
# updated; everything else in the file stays frozen. Triggered by
# ukishima-scheme-sync.path on every palette change.
set -eu
SRC="${XDG_CACHE_HOME:-$HOME/.cache}/ukishima/colors.json"
DST="$HOME/.config/hypr/scheme/current.lua"
[ -f "$SRC" ] || exit 0
[ -f "$DST" ] || exit 0
python3 - "$SRC" "$DST" <<'EOF'
import json, re, sys
src, dst = sys.argv[1], sys.argv[2]
c = json.load(open(src))
def h(k, fb='000000'):
    return str(c.get(k, fb)).lstrip('#')
# scheme key -> colors.json key
mapping = {
    # live keys (actually referenced by modules/*.lua + variables)
    'primary': 'primary',
    'onPrimary': 'bright',
    'primaryContainer': 'primary_container',
    'onPrimaryContainer': 'on_primary_container',
    'secondary': 'subtle',
    'surfaceContainer': 'surface_container',
    'onSurfaceVariant': 'subtle',
    'inversePrimary': 'dim',
    'outline': 'outline',
    # base structure (kept coherent for future use)
    'background': 'surface',
    'onBackground': 'bright',
    'surface': 'surface',
    'onSurface': 'bright',
    'surfaceDim': 'surface',
    'surfaceBright': 'surface_container_highest',
    'surfaceContainerLowest': 'surface_container_low',
    'surfaceContainerLow': 'surface_container_low',
    'surfaceContainerHigh': 'surface_container_high',
    'surfaceContainerHighest': 'surface_container_highest',
    'surfaceVariant': 'surface_container_high',
    'outlineVariant': 'outline_variant',
    'surfaceTint': 'primary',
}
s = open(dst).read()
n = 0
for skey, ckey in mapping.items():
    pat = re.compile(r'(\b%s\s*=\s*")[0-9a-fA-F]{6}(")' % re.escape(skey))
    s2, cnt = pat.subn(r'\g<1>%s\g<2>' % h(ckey), s, count=1)
    if cnt:
        s, n = s2, n + 1
open(dst, 'w').write(s)
print(f'scheme sync: {n} keys updated')
EOF
# best-effort live reload (no-op outside a Hyprland session)
RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
sock=$(ls -t "$RT"/hypr/*/.socket.sock 2>/dev/null | head -n1 || true)
if [ -n "$sock" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(basename "$(dirname "$sock")")
    hyprctl reload >/dev/null 2>&1 || true
fi
