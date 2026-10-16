local vars = require("variables")
local fn   = require("utils.functions")


-- Flags
local locked           = { locked = true }
local mouse            = { mouse = true }
local release          = { release = true }
local repeating        = { repeating = true }
local locked_repeating = { locked = true, repeating = true }

local function normalise_keybind(key)
    return key:gsub("%s+", ""):lower()
end

local function valid_keybind(key)
    return type(key) == "string" and key:match("%S") ~= nil
end

local function repeating_unless_mouse(key)
    return not normalise_keybind(key):find("mouse", 1, true) and repeating or nil
end

local function flatten_keybinds(keybinds, keys)
    keys = keys or {}

    if type(keybinds) == "table" then
        for _, keybind in pairs(keybinds) do
            flatten_keybinds(keybind, keys)
        end
    elseif valid_keybind(keybinds) then
        keys[#keys + 1] = keybinds
    end

    return keys
end

local function create_bind(keybinds, action, flags)
    local get_flags = type(flags) == "function" and flags or function()
        return flags
    end

    for _, key in ipairs(flatten_keybinds(keybinds)) do
        hl.bind(key, action, get_flags(key))
    end
end

local function extend_keybind(base, suffix)
    return valid_keybind(base) and base .. " + " .. suffix or nil
end

-- Ukishima IPC helper (used by all shell binds below)
local uki = os.getenv("HOME") .. "/.local/share/quickshell/ukishima"
local function ukishima(handler, extra)
    -- hide/unloadAll are zero-argument handlers; all other surface handlers
    -- take an empty monitor selector so they follow the focused monitor.
    if handler == "hide" or handler == "unloadAll" then
        return hl.dsp.exec_cmd("qs -p " .. uki .. " ipc call ukishima " .. handler)
    end
    return hl.dsp.exec_cmd("qs -p " .. uki .. " ipc call ukishima " .. handler .. " \"\"" .. (extra and " " .. extra or ""))
end

local function minimize_active()
    local win = hl.get_active_window()
    if win then
        hl.dispatch(hl.dsp.window.move({
            workspace = "special:minimized",
            window = win,
            follow = false,
        }))
    end
end

local function restore_minimized()
    local active = hl.get_active_workspace()
    local minimized = hl.get_workspace_windows("special:minimized")
    local win = minimized and minimized[1]
    if active and win and active.name ~= "special:minimized" then
        hl.dispatch(hl.dsp.window.move({
            workspace = active,
            window = win,
            follow = true,
        }))
    end
end

-- Launcher (Ukishima, SUPER + space only)
create_bind(vars.kbLauncher, ukishima("launcher"))

-- Session / lock (Ukishima power surface + hyprlock)
create_bind(vars.kbSession, ukishima("power"))
create_bind(vars.kbLock, hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/share/quickshell/ukishima/scripts/lock.sh"))
-- NOTE: kbShowSidebar / kbClearNotifs / kbShowPanels have no Ukishima IPC
-- equivalent — use the pill (hover) for the control centre + notifications.

-- Restore lock
create_bind(vars.kbRestoreLock, hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/share/quickshell/ukishima/scripts/lock.sh"))

-- Kill/restart (Ukishima)
create_bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -p " .. uki .. " kill; sleep .5; " .. uki .. "/launch.sh -d"), release)
create_bind("CTRL + SUPER + ALT + R", hl.dsp.exec_cmd("qs -p " .. uki .. " kill"), release)

-- Ukishima surfaces (fire on press, not release, for instant response;
-- no repeat flag is set so holding the combo won't re-trigger)
-- Surfaces
-- Wallpaper strip (home wallpapers, matugen-driven)
create_bind("SUPER + SHIFT + W", ukishima("wallpaper"))
create_bind("SUPER + SHIFT + V", ukishima("clipboard"))
create_bind("SUPER + SHIFT + A", ukishima("mixer"))
create_bind("SUPER + SHIFT + D", ukishima("calendar"))
create_bind("SUPER + SHIFT + P", ukishima("media"))
create_bind("SUPER + SHIFT + X", ukishima("power"))
create_bind("SUPER + SHIFT + E", ukishima("link"))
create_bind("SUPER + SHIFT + U", ukishima("battery"))
create_bind("SUPER + SHIFT + Y", ukishima("sysmon"))
create_bind("SUPER + SHIFT + R", ukishima("recorder"))
-- Workspace overview: a horizontal row of per-workspace live previews, drawn
-- inside the pill. SUPER+TAB was the first choice but that is the muscle memory
-- for alt-tab style window cycling, so this takes the SHIFT variant instead.
create_bind("SUPER + SHIFT + TAB", ukishima("overview"))
create_bind("SUPER + ALT + I", ukishima("page", "wifi"))
-- Toggles and actions
create_bind("SUPER + ALT + Q", ukishima("quickRecord"))
create_bind("SUPER + ALT + G", ukishima("gameMode"))
create_bind("SUPER + ALT + E", ukishima("peek"))
create_bind("SUPER + ALT + H", ukishima("hide"))
create_bind("SUPER + ALT + D", minimize_active)
create_bind("SUPER + ALT + U", restore_minimized)
create_bind("SUPER + SHIFT + Delete", ukishima("unloadAll"))

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    create_bind(extend_keybind(vars.kbGoToWs, key), fn.wsaction("focus", "", i))
    create_bind(extend_keybind(vars.kbMoveWinToWs, key), fn.wsaction("move", "", i))
    create_bind(extend_keybind(vars.kbGoToWsGroup, key), fn.wsaction("focus", "group", i))
    create_bind(extend_keybind(vars.kbMoveWinToWsGroup, key), fn.wsaction("move", "group", i))
end

-- Go to workspace -1/+1
create_bind(vars.kbPrevWs, hl.dsp.focus({ workspace = "-1" }), repeating_unless_mouse)
create_bind(vars.kbNextWs, hl.dsp.focus({ workspace = "+1" }), repeating_unless_mouse)

-- Go to workspace group -1/+1
create_bind(vars.kbPrevWsGroup, hl.dsp.focus({ workspace = "-10" }), repeating_unless_mouse)
create_bind(vars.kbNextWsGroup, hl.dsp.focus({ workspace = "+10" }), repeating_unless_mouse)

-- Move window to workspace -1/+1
create_bind(vars.kbMoveWinToWsNext, hl.dsp.window.move({ workspace = "+1" }), repeating_unless_mouse)
create_bind(vars.kbMoveWinToWsPrev, hl.dsp.window.move({ workspace = "-1" }), repeating_unless_mouse)

-- Move window to/from special workspace
create_bind(vars.kbMoveWinToWsSpecial, hl.dsp.window.move({ workspace = "special:special" }))
create_bind(vars.kbMoveWinFromWsSpecial, hl.dsp.window.move({ workspace = "e+0" }))

-- Window groups
create_bind(vars.kbWindowCycleNext, hl.dsp.window.cycle_next(), repeating)
create_bind(vars.kbWindowCyclePrev, hl.dsp.window.cycle_next({ next = false }), repeating)
create_bind(vars.kbWindowGroupCycleNext, hl.dsp.group.next(), repeating)
create_bind(vars.kbWindowGroupCyclePrev, hl.dsp.group.prev(), repeating)
create_bind(vars.kbToggleGroup, hl.dsp.group.toggle())
create_bind(vars.kbUngroup, hl.dsp.window.move({ out_of_group = true }))
create_bind(vars.kbGroupLockActive, hl.dsp.group.lock_active())

-- Window actions
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    create_bind("SUPER + " .. dir, hl.dsp.focus({ direction = dir }))
    create_bind("SUPER + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

create_bind(vars.kbWindowDecreaseWidth, fn.resize_active_window(-10, 0), repeating)
create_bind(vars.kbWindowIncreaseWidth, fn.resize_active_window(10, 0), repeating)
create_bind(vars.kbWindowDecreaseHeight, fn.resize_active_window(0, -10), repeating)
create_bind(vars.kbWindowIncreaseHeight, fn.resize_active_window(0, 10), repeating)

create_bind({ vars.kbMoveWindow, "SUPER + mouse:272" }, hl.dsp.window.drag(), mouse)
create_bind({ vars.kbResizeWindow, "SUPER + mouse:273" }, hl.dsp.window.resize(), mouse)
create_bind(vars.kbCenterWindow, hl.dsp.window.center())
create_bind(vars.kbNormalizeWindow, function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
    hl.dispatch(hl.dsp.window.center())
end)
create_bind(vars.kbWindowPip, function()
    local a = hl.get_active_window()
    if a then
        local pip = fn.move_actions(a) or {}
        if not a.floating then table.insert(pip, 1, hl.dsp.window.float()) end
        table.insert(pip, hl.dsp.window.pin({ action = "on", window = "address:" .. a.address }))

        for _, x in ipairs(pip) do
            hl.dispatch(x)
        end
    end
end)
create_bind(vars.kbPinWindow, hl.dsp.window.pin())
create_bind(vars.kbWindowFullscreen, hl.dsp.window.fullscreen({ mode = "fullscreen" }))
create_bind(vars.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized" }))
create_bind(vars.kbToggleWindowFloating, hl.dsp.window.float())
create_bind(vars.kbCloseWindow, hl.dsp.window.close())

-- Special workspace toggles
create_bind(vars.kbSpecialWs, fn.toggle("specialws"))
create_bind(vars.kbSystemMonitorWs, fn.toggle("sysmon"))
-- Music workspace: toggle it when a player is running; otherwise use Fuzzel.
create_bind(vars.kbMusicWs, hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/music-picker.sh"))
create_bind(vars.kbCommunicationWs, fn.toggle("communication"))
create_bind(vars.kbObsidianWs, fn.toggle("obsidian"))
create_bind(vars.kbWindowsWs, fn.toggle("windows"))
create_bind(vars.kbGamesWs, fn.toggle("games"))

-- Apps
create_bind(vars.kbTerminal, hl.dsp.exec_cmd(vars.terminal))
create_bind(vars.kbBrowser, hl.dsp.exec_cmd(vars.browser))
create_bind(vars.kbEditor, hl.dsp.exec_cmd(vars.editor))
create_bind(vars.kbFileExplorer, hl.dsp.exec_cmd(vars.fileExplorer))
create_bind(vars.kbAudioSettings, hl.dsp.exec_cmd(vars.audioSettings))

-- Zeron: focus the running instance, or launch it if not up yet.
-- Appshot tells the already-running instance to capture (needs it open).
create_bind(vars.kbZeron, fn.launch_or_focus("zeron", vars.zeron))
create_bind(vars.kbZeronAppshot, hl.dsp.exec_cmd(vars.zeron .. " appshot"))

-- Utilities (hyprshot/grim+satty -> ~/Pictures/Screenshots + clipboard + notification, Ukishima recorder)
create_bind(vars.kbScreenshot, hl.dsp.exec_cmd([[sh -c 'mkdir -p ~/Pictures/Screenshots && f=~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png && grim "$f" && wl-copy < "$f" && notify-send -a Screenshot -u low -i "$f" "Screenshot saved" "$f"']]), locked)
-- Freeze variant: hyprshot freezes the frame (-z) so animated content won't shift during selection.
create_bind(vars.kbScreenshotFreeze, hl.dsp.exec_cmd([[sh -c 'mkdir -p ~/Pictures/Screenshots && hyprshot -m region -z -o ~/Pictures/Screenshots -f "$(date +%F_%H-%M-%S).png"']]), locked)
-- Annotate variant (ryoshot-lite): region pick piped into satty for arrows/text/blur, saves + copies.
create_bind(vars.kbScreenshotRegion, hl.dsp.exec_cmd([[sh -c 'mkdir -p ~/Pictures/Screenshots && f=~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png && grim -g "$(slurp)" - | satty --filename - --output-filename "$f" --copy-command wl-copy && notify-send -a Screenshot -u low -i "$f" "Screenshot saved" "$f"']]), locked)
create_bind(vars.kbRecord, ukishima("recorder"))
create_bind(vars.kbRecordSound, ukishima("quickRecord"))
create_bind(vars.kbRecordRegion, ukishima("recorder"))
create_bind(vars.kbColorPicker, hl.dsp.exec_cmd("hyprpicker -a"))

-- Brightness
create_bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"), locked)
create_bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), locked)

-- Media (playerctl)
create_bind({ vars.kbMediaToggle, "XF86AudioPlay", "XF86AudioPause" }, hl.dsp.exec_cmd("playerctl play-pause"), locked)
create_bind({ vars.kbMediaNext, "XF86AudioNext" }, hl.dsp.exec_cmd("playerctl next"), locked)
create_bind({ vars.kbMediaPrev, "XF86AudioPrev" }, hl.dsp.exec_cmd("playerctl previous"), locked)
create_bind({ vars.kbMediaStop, "XF86AudioStop" }, hl.dsp.exec_cmd("playerctl stop"), locked)

-- Volume
create_bind({ vars.kbVolumeMute, "XF86AudioMute" }, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked)
create_bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), locked)
create_bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " ..
        (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"
    ),
    locked_repeating
)
create_bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"
    ),
    locked_repeating
)

-- Sleep
create_bind(vars.kbSleep, hl.dsp.exec_cmd(vars.sleepGestureCmd), locked)

-- Clipboard (Ukishima surface; no emoji picker installed — see note in summary)
create_bind(vars.kbClipboard, ukishima("clipboard"))
create_bind(vars.kbClipboardDel, ukishima("clipboard"))
create_bind(
    vars.kbClipboardPasteLatest,
    hl.dsp.exec_cmd('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'),
    locked
)

-- Testing
create_bind(
    "SUPER + ALT + F12",
    hl.dsp.exec_cmd(
        "notify-send -u low -i dialog-information-symbolic 'Test notification' " ..
        [["Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!"]] ..
        " -a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'"
    )
)

-- Resize mode (Ryoku resize submap): SUPER+R enters, arrows/hjkl resize, Esc exits.
-- modules/resize.lua owns the submap; this is just the entry chord.
if vars.kbResizeMode and vars.kbResizeMode:match("%S") then
    hl.bind(vars.kbResizeMode, hl.dsp.submap("resize"))
end
-- Direct resize without entering the mode (same 40px step as the submap).
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    local dx = (dir == "left" and -40) or (dir == "right" and 40) or 0
    local dy = (dir == "up" and -40) or (dir == "down" and 40) or 0
    hl.bind("SUPER + CTRL + " .. dir, hl.dsp.window.resize({ x = dx, y = dy, relative = true }), repeating)
end

-- Layout actions (each is a no-op unless its layout is active)
if vars.kbDwindleToggleSplit and vars.kbDwindleToggleSplit:match("%S") then
    hl.bind(vars.kbDwindleToggleSplit, hl.dsp.layout("togglesplit"))
end
if vars.kbDwindlePseudo and vars.kbDwindlePseudo:match("%S") then
    hl.bind(vars.kbDwindlePseudo, hl.dsp.window.pseudo())
end
if vars.kbMasterSwapWithMaster and vars.kbMasterSwapWithMaster:match("%S") then
    hl.bind(vars.kbMasterSwapWithMaster, hl.dsp.layout("swapwithmaster"))
end
if vars.kbMasterFocusMaster and vars.kbMasterFocusMaster:match("%S") then
    hl.bind(vars.kbMasterFocusMaster, hl.dsp.layout("focusmaster"))
end
if vars.kbMasterOrientationNext and vars.kbMasterOrientationNext:match("%S") then
    hl.bind(vars.kbMasterOrientationNext, hl.dsp.layout("orientationnext"))
end
if vars.kbMasterAdd and vars.kbMasterAdd:match("%S") then
    hl.bind(vars.kbMasterAdd, hl.dsp.layout("addmaster"))
end
if vars.kbMasterRemove and vars.kbMasterRemove:match("%S") then
    hl.bind(vars.kbMasterRemove, hl.dsp.layout("removemaster"))
end
if vars.kbScrollingPromote and vars.kbScrollingPromote:match("%S") then
    hl.bind(vars.kbScrollingPromote, hl.dsp.layout("promote"))
end
if vars.kbScrollingConsume and vars.kbScrollingConsume:match("%S") then
    hl.bind(vars.kbScrollingConsume, hl.dsp.layout("consume"))
end

-- Live layout switching (no reload needed).
-- `hyprctl keyword` is a no-op on 0.55+ ("keyword can't work with
-- non-legacy parsers"), so switch via the Lua config API instead — hl.config
-- merges at runtime exactly like it does at load.
local function set_layout(name)
    return function()
        hl.config({ general = { layout = name } })
    end
end

if vars.kbLayoutDwindle and vars.kbLayoutDwindle:match("%S") then
    hl.bind(vars.kbLayoutDwindle, set_layout("dwindle"))
end
if vars.kbLayoutMaster and vars.kbLayoutMaster:match("%S") then
    hl.bind(vars.kbLayoutMaster, set_layout("master"))
end
if vars.kbLayoutScrolling and vars.kbLayoutScrolling:match("%S") then
    hl.bind(vars.kbLayoutScrolling, set_layout("scrolling"))
end
