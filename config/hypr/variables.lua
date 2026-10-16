-- =====================================================================
-- variables.lua — the single place for all tunables.
-- Every module under hyprland/ reads from this table. Edit values here,
-- then `hyprctl reload` to apply.
-- =====================================================================
local scheme = require("scheme.current")

-- Wallpaper-driven borders (Ukishima wallcolors.py writes this on every
-- wallpaper change + `hyprctl reload`). Falls back to scheme.current when
-- the cache is missing (first run before any wallpaper is set).
local function load_hypr_colors()
	local cache = os.getenv("XDG_CACHE_HOME")
	if not cache or cache == "" then
		cache = (os.getenv("HOME") or "") .. "/.cache"
	end
	local ok, mod = pcall(dofile, cache .. "/ukishima/hypr-colors.lua")
	if ok and type(mod) == "table" then
		return mod
	end
	return nil
end
local hypr_colors = load_hypr_colors()
local function hex(c)
	return ((c or ""):gsub("#", ""))
end
local activeBorderHex = hex(hypr_colors and hypr_colors.active or scheme.primary)
local inactiveBorderHex = hex(hypr_colors and hypr_colors.inactive or scheme.onSurfaceVariant)

return {
	------------------
	---- HYPRLAND ----
	------------------

	-- Apps
	terminal = "foot",
	browser = "firefox",
	editor = "zeditor",
	fileExplorer = "thunar",
	audioSettings = "pwvucontrol",
	zeron = "zeron",

	-- Touchpad
	touchpadDisableTyping = true,
	touchpadScrollFactor = 0.3,
	gestureFingers = 3,
	workspaceSwipeFingers = 4,
	gestureFingersMore = 4,

	-- Blur
	blurEnabled = true,
	blurSpecialWs = true,
	blurPopups = true,
	blurInputMethods = true,
	blurSize = 6,
	blurPasses = 2,
	blurXray = false,

	-- Shadow
	shadowEnabled = true,
	shadowRange = 12,
	shadowRenderPower = 3,
	shadowColour = "rgba(0000008c)",

	-- Gaps
	workspaceGaps = 20,
	windowGapsIn = 5,
	windowGapsOut = 10,
	singleWindowGapsOut = 20,

	-- Window styling
	windowOpacity = 1,
	windowRounding = 20,
	windowRoundingPower = 4,
	windowBorderSize = 0,
	activeWindowBorderColour = "rgba(" .. activeBorderHex .. "e6)",
	inactiveWindowBorderColour = "rgba(" .. inactiveBorderHex .. "11)",

	-- Misc
	volumeStep = 10,
	volumeMax = 150, -- keybind cap in %; maps to wpctl set-volume -l 2.0
	-- Available cursor themes (/usr/share/icons/*/cursors):
	-- "Adwaita" (adwaita-cursors), "breeze_cursors" / "Breeze_Light" (breeze-cursors),
	-- "macOS" / "macOS-White" (apple_cursor), "macos-tahoe-cursor" (macos-tahoe-cursor)
	cursorTheme = "macos-tahoe-cursor",
	cursorSize = 24,
	sleepGestureCmd = "systemctl suspend",

	-- Mouse focus (0 = hover never steals focus / switches monitor)
	followMouse = 0, -- input:follow_mouse
	mouseMoveFocusesMonitor = false, -- misc:mouse_move_focuses_monitor

	-- Qt / Quickshell scaling (needs relog). 1.0 = compositor scale wins.
	qtScaleFactor = 1.0,
	qtAutoScreenScale = true, -- maps to QT_AUTO_SCREEN_SCALE_FACTOR 1/0

	------------------
	---- LAYOUT ----
	------------------
	-- "dwindle" | "master" | "scrolling". Live-switch with
	-- kbLayoutDwindle/Master/Scrolling, persist by changing this.
	layout = "scrolling",

	-- Dwindle (BSPWM-like binary tree)
	dwindlePreserveSplit = true,
	dwindleSmartSplit = false,
	dwindleSmartResizing = true,
	dwindleSplitWidthMultiplier = 1.0,
	dwindleDefaultSplitRatio = 1.0,

	-- Master (one master + slave stack)
	masterMfact = 0.55,
	masterOrientation = "left", -- "left" | "right" | "top" | "bottom" | "center"
	masterNewStatus = "slave", -- "master" | "slave" | "inherit"
	masterNewOnTop = false,
	masterSmartResizing = true,
	masterDropAtCursor = true,

	-- Scrolling (tape of columns)
	scrollingColumnWidth = 0.97,
	scrollingFullscreenOneColumn = true,
	scrollingFocusFitMethod = 1, -- 0 = center, 1 = fit
	scrollingFollowFocus = true,

	-- Layout keybinds
	kbDwindleToggleSplit = "SUPER + J",
	kbDwindlePseudo = "SUPER + SHIFT + G",
	kbMasterSwapWithMaster = "SUPER + ALT + J",
	kbMasterFocusMaster = "SUPER + ALT + K",
	kbMasterOrientationNext = "SUPER + ALT + O",
	kbMasterAdd = "SUPER + ALT + A",
	kbMasterRemove = "SUPER + ALT + X",
	kbScrollingPromote = "SUPER + ALT + P",
	kbScrollingConsume = "SUPER + ALT + C",
	kbLayoutDwindle = "SUPER + SHIFT + 1",
	kbLayoutMaster = "SUPER + SHIFT + 2",
	kbLayoutScrolling = "SUPER + SHIFT + 3",

	------------------
	---- MONITORS ----
	------------------
	-- "" = wildcard fallback for any output. Set monitorOutput (e.g. "eDP-1")
	-- to pin an explicit rule; extraMonitors = list of { output, mode,
	-- position, scale, vrr, transform } applied in order.
	monitorOutput = "",
	monitorMode = "preferred",
	monitorPosition = "auto",
	monitorScale = 1,
	monitorVrr = 0,
	monitorTransform = 0,
	extraMonitors = {},

	------------------
	---- LOOK ----
	------------------
	-- Animation preset: files in modules/anim-presets/*.lua, "off" disables.
	-- Available: fade | fast | m3 | minimal | off | smooth | snappy
	-- (anything else falls back to "m3" — see modules/animations.lua)
	animationPreset = "m3",

	------------------
	---- KEYBINDS ----
	------------------

	-- Modifier only, the actual binds will be mod + 0-9. These should be strings and not arrays.
	kbGoToWs = "SUPER",
	kbGoToWsGroup = "CTRL + SUPER",
	kbMoveWinToWs = "SUPER + ALT",
	kbMoveWinToWsGroup = "CTRL + SUPER + ALT",

	-- All the following binds can be either an array of binds to bind multiple keys, or a single string.

	-- Workspaces
	kbMoveWinToWsSpecial = { "SUPER + ALT + S", "CTRL + SUPER + SHIFT + Up" },
	kbMoveWinFromWsSpecial = "CTRL + SUPER + SHIFT + Down",
	kbMoveWinToWsNext = { "SUPER + ALT + mouse_down", "SUPER + ALT + Page_Down", "CTRL + SUPER + SHIFT + Right" },
	kbMoveWinToWsPrev = { "SUPER + ALT + mouse_up", "SUPER + ALT + Page_Up", "CTRL + SUPER + SHIFT + Left" },
	kbNextWs = { "SUPER + mouse_down", "CTRL + SUPER + Right", "SUPER + Page_Down" },
	kbPrevWs = { "SUPER + mouse_up", "CTRL + SUPER + Left", "SUPER + Page_Up" },
	kbNextWsGroup = "CTRL + SUPER + mouse_down",
	kbPrevWsGroup = "CTRL + SUPER + mouse_up",

	-- Window Group
	kbWindowCycleNext = "ALT + TAB",
	kbWindowCyclePrev = "SHIFT + ALT + TAB",
	kbWindowGroupCycleNext = "CTRL + ALT + TAB",
	kbWindowGroupCyclePrev = "CTRL + SHIFT + ALT + TAB",
	kbUngroup = "SUPER + U",
	kbToggleGroup = "SUPER + Comma",
	kbGroupLockActive = "SUPER + SHIFT + Comma",

	-- Window Actions
	kbWindowDecreaseWidth = { "SUPER + Minus", "SUPER + ALT + Left" },
	kbWindowIncreaseWidth = { "SUPER + Equal", "SUPER + ALT + Right" },
	kbWindowDecreaseHeight = { "SUPER + SHIFT + Minus", "SUPER + ALT + Up" },
	kbWindowIncreaseHeight = { "SUPER + SHIFT + Equal", "SUPER + ALT + Down" },

	kbMoveWindow = "SUPER + Z",
	kbResizeWindow = "SUPER + X",
	kbResizeMode = "SUPER + R",
	kbCenterWindow = "CTRL + SUPER + Backslash",
	kbNormalizeWindow = "CTRL + SUPER + ALT + Backslash",
	kbWindowPip = "SUPER + ALT + Backslash",
	kbPinWindow = "SUPER + P",
	kbWindowFullscreen = "SUPER + F",
	kbWindowBorderedFullscreen = "SUPER + ALT + F",
	kbToggleWindowFloating = "SUPER + ALT + Space",
	kbCloseWindow = "SUPER + Q",

	-- Special workspaces toggles
	kbSpecialWs = "SUPER + S",
	kbSystemMonitorWs = "CTRL + SHIFT + Escape",
	kbMusicWs = "SUPER + M", -- Toggle music workspace; Fuzzel when no player runs
	kbCommunicationWs = "SUPER + D",
	-- Was SUPER + R, which kbResizeMode also claims: the resize submap is
	-- registered later, so the Obsidian toggle was silently unreachable.
	kbObsidianWs = "SUPER + N",
	kbWindowsWs = "SUPER + O",
	kbGamesWs = "SUPER + G",

	-- Apps
	kbTerminal = "SUPER + T",
	kbBrowser = "SUPER + W",
	kbEditor = "SUPER + C",
	kbFileExplorer = "SUPER + E",
	kbAudioSettings = "CTRL + ALT + V",

	-- Zeron (multi-device controller for coding agents)
	kbZeron = "SUPER + A",
	kbZeronAppshot = "SUPER + SHIFT + Z",

	-- Utilities
	kbScreenshot = "Print",
	kbScreenshotFreeze = "SUPER + SHIFT + S",
	kbScreenshotRegion = "SUPER + SHIFT + ALT + S",
	kbRecord = "CTRL + ALT + R",
	kbRecordSound = "SUPER + ALT + R",
	kbRecordRegion = "SUPER + SHIFT + ALT + R",
	kbColorPicker = "SUPER + SHIFT + C",

	-- Media
	kbMediaToggle = "CTRL + SUPER + Space",
	kbMediaNext = "CTRL + SUPER + Equal",
	kbMediaPrev = "CTRL + SUPER + Minus",
	kbMediaStop = "CTRL + SUPER + Backspace",
	kbVolumeMute = "SUPER + SHIFT + M",

	-- Misc
	kbLauncher = "SUPER + space",
	kbSession = "CTRL + ALT + Delete",
	kbLock = "SUPER + L",
	kbRestoreLock = "SUPER + ALT + L",
	kbSleep = "SUPER + SHIFT + L",

	-- Clipboard
	kbClipboard = "SUPER + V",
	kbClipboardDel = "SUPER + ALT + V",
	kbClipboardPasteLatest = "CTRL + SHIFT + ALT + V",
}
