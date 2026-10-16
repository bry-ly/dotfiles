local vars = require("variables")
local fn   = require("utils.functions")

hl.on("hyprland.start", function()
    -- Start shell FIRST so IPC binds (launcher, clipboard, surfaces) go live
    -- ASAP; everything below is fire-and-forget and can settle after.
    hl.exec_cmd("pgrep -x awww-daemon || awww-daemon")

    hl.exec_cmd(os.getenv("HOME") .. "/.local/share/quickshell/ukishima/launch.sh -d")

    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    -- No external polkit agent: Ukishima has one built in (Polkit.qml,
    -- pill-styled). A second agent would double-prompt.

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Night light (gammastep + geoclue) intentionally absent: neither is
    -- installed. To enable: sudo pacman -S gammastep geoclue, then add
    --   hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
    --   hl.exec_cmd("sleep 1 && gammastep")

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Idle daemon (lock / DPMS / suspend per ~/.config/hypr/hypridle.conf)
    hl.exec_cmd("pidof hypridle || hypridle")
end)

-- Resizer listeners
local function apply_resizer_rules(win)
    local float_center = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
    local pip_actions = fn.move_actions(win) or {}

    -- Bitwarden
    fn.resizer(win, "Bitwarden", 20, 54, float_center, true, "class")                                       -- Native app
    fn.resizer(win, "^Extension: %(Bitwarden Password Manager%) %- Bitwarden", 20, 54, float_center, false) -- Firefox
    fn.resizer(win, "nngceckbapebfimnlniiiahkandclblb", 20, 54, float_center, true, "class")                -- Chromium

    -- Picture in picture
    fn.resizer(win, "Picture[- ]in[- ][Pp]icture", 0, 0, pip_actions, false)
end

hl.on("window.title", apply_resizer_rules)
hl.on("window.open", apply_resizer_rules)

-- Noctalia autostart disabled (2026-09-23, back to Ukishima): uncomment to re-enable.
-- hl.on("hyprland.start", function()
--   hl.exec_cmd("noctalia")
-- end)
