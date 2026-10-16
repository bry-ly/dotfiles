-- Animation preset loader. Single source: `animationPreset` in variables.lua
-- selects one self-contained set under modules/anim-presets/.
-- "off" disables all animations. Edit variables.lua, then `hyprctl reload`.
local vars = require("variables")

local function cfg(sub)
    local base = os.getenv("XDG_CONFIG_HOME")
    if not base or base == "" then
        base = (os.getenv("HOME") or "") .. "/.config"
    end
    return base .. sub
end

-- Probe the file so a stale name never trips Hyprland's config-error overlay.
-- Must mirror the require() target below.
local function shipped(name)
    local f = io.open(cfg("/hypr/modules/anim-presets/" .. name .. ".lua"), "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Each preset is self-contained: it sets animations.enabled itself plus its
-- own curves and leaves. No shared pre-curves here, so a preset rename can
-- never leave a dangling bezier reference behind.
local name = vars.animationPreset
if type(name) ~= "string" or not name:match("^[%w_]+$") or not shipped(name) then
    name = "m3"
end

require("modules.anim-presets." .. name)
