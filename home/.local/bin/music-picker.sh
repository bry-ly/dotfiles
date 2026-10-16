#!/usr/bin/env bash
# Toggle the music workspace when a player is already running. If neither
# player is running, use Fuzzel to choose one. Selecting a client closes the
# other client so they cannot fight over audio.
set -Eeuo pipefail

readonly music_workspace='special:music'
readonly spotify_pattern='^(Spotify|spotify)( Free)?$'
readonly spotifast_pattern='^(fastpotify|spotifast)$'
readonly music_pattern='^(Spotify|spotify)( Free)?$|^(fastpotify|spotifast)$'
readonly spotify_icon='spotify-client,spotify'
readonly spotifast_icon='spotifast'

notify_error() {
    local message=$1
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical -a 'Music picker' "$message" >/dev/null 2>&1 || true
    fi
}

require_command() {
    local command_name=$1
    if ! command -v "$command_name" >/dev/null 2>&1; then
        notify_error "Music picker needs ${command_name}."
        return 1
    fi
}

hypr_dispatch() {
    local expression=$1
    if ! hyprctl dispatch "$expression" >/dev/null; then
        notify_error 'Could not control Hyprland.'
        return 1
    fi
}

# Return client addresses matching a class, initial class, or title.
# Spotify and Spotifast have used different class names across Wayland/Xwayland.
matching_addresses() {
    local pattern=$1
    local clients

    if ! clients=$(hyprctl clients -j 2>/dev/null); then
        return 0
    fi

    if ! printf '%s' "$clients" | jq -r --arg pattern "$pattern" '
        .[]
        | select(
            (
                ((.class // "") | test($pattern; "i")) or
                ((.initialClass // "") | test($pattern; "i")) or
                ((.title // "") | test($pattern; "i"))
            )
        )
        | .address
    '; then
        return 0
    fi
}

is_music_workspace_open() {
    local monitors

    if ! monitors=$(hyprctl monitors -j 2>/dev/null); then
        return 1
    fi

    # activeworkspace always reports the last normal workspace. The open
    # special workspace is exposed separately as monitor.specialWorkspace.
    if printf '%s' "$monitors" | jq -e --arg name "$music_workspace" \
        'any(.[]; (.specialWorkspace.name? // "") == $name)' >/dev/null; then
        return 0
    fi
    return 1
}

open_existing_players() {
    local -a addresses=("$@")
    local address

    # Open the special workspace before moving windows into it.
    hypr_dispatch "hl.dsp.focus({ workspace = \"${music_workspace}\" })"

    if ((${#addresses[@]} == 0)); then
        return 0
    fi

    for address in "${addresses[@]}"; do
        hypr_dispatch "hl.dsp.window.move({ window = \"address:${address}\", workspace = \"${music_workspace}\", follow = false })"
    done
    hypr_dispatch "hl.dsp.focus({ window = \"address:${addresses[0]}\" })"
}

close_player() {
    local pattern=$1
    local address

    while IFS= read -r address; do
        [[ -n "$address" ]] || continue
        # A player can disappear between querying clients and dispatching.
        hyprctl dispatch "hl.dsp.window.close({ window = \"address:${address}\" })" >/dev/null 2>&1 || true
    done < <(matching_addresses "$pattern")
}

open_player() {
    local pattern=$1
    local command_name=$2
    local address
    local -a addresses=()

    mapfile -t addresses < <(matching_addresses "$pattern")

    # Open the special workspace first so a newly launched client is visible.
    hypr_dispatch "hl.dsp.focus({ workspace = \"${music_workspace}\" })"

    if ((${#addresses[@]} > 0)); then
        # Reuse an already-running client instead of starting a second instance.
        for address in "${addresses[@]}"; do
            hypr_dispatch "hl.dsp.window.move({ window = \"address:${address}\", workspace = \"${music_workspace}\", follow = false })"
        done
        hypr_dispatch "hl.dsp.focus({ window = \"address:${addresses[0]}\" })"
    else
        hypr_dispatch "hl.dsp.exec_cmd(\"${command_name}\", { workspace = \"${music_workspace}\" })"
    fi
}

require_command hyprctl
require_command jq

# A running player is a guard: reuse it and toggle/open the workspace instead
# of opening Fuzzel again. With no player, show the chooser.
declare -a running_addresses=()
mapfile -t running_addresses < <(matching_addresses "$music_pattern")

if ((${#running_addresses[@]} > 0)); then
    if is_music_workspace_open; then
        # SUPER+M closes the special workspace when it is already open.
        hypr_dispatch 'hl.dsp.workspace.toggle_special("music")'
    else
        # SUPER+M opens the workspace and brings the existing player with it.
        open_existing_players "${running_addresses[@]}"
    fi
    exit 0
fi

# No player is running: let the user choose one.
require_command fuzzel
require_command spotify
require_command spotifast

# Fuzzel's extended dmenu protocol carries an icon name after each entry.
# --index keeps the icon metadata out of the selected value, so the guard and
# launcher logic still use stable 0/1 choices. The explicit colors below keep
# this card aligned with Ukishima's dark warm pill.
if ! choice=$(printf '%s\0icon\x1f%s\n%s\0icon\x1f%s\n' \
    'Spotify' "$spotify_icon" 'Spotifast' "$spotifast_icon" |
    fuzzel --dmenu --index --only-match \
        --prompt='Music app ' \
        --placeholder='Choose Spotify or Spotifast' \
        --match-mode=fuzzy --fuzzy-min-length=1 \
        --width=46 --lines=4 --minimal-lines \
        --font='JetBrains Mono NF:size=16' --line-height=30 \
        --horizontal-pad=18 --vertical-pad=12 --inner-pad=8 \
        --icon-theme=Papirus --selection-radius=8 \
        --border-radius=12 --border-width=1 --counter \
        --background-color=141312dd --text-color=e7e1dfdd \
        --prompt-color=d3c4b7ff --placeholder-color=998f87ff \
        --input-color=e7e1dfff --match-color=cac7b9ff \
        --selection-color=d3c4b787 --selection-text-color=e7e1dfff \
        --selection-match-color=cac7b9ff --counter-color=998f87ff \
        --border-color=d3c4b777); then
    # Escape/closing the menu is a normal no-op.
    exit 0
fi

case "$choice" in
    0)
        close_player "$spotifast_pattern"
        open_player "$spotify_pattern" spotify
        ;;
    1)
        close_player "$spotify_pattern"
        open_player "$spotifast_pattern" spotifast
        ;;
    *)
        # Ignore unexpected/custom Fuzzel output.
        exit 0
        ;;
esac
