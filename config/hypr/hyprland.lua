local home = os.getenv("HOME")
local hypr = home .. "/.config/hypr"

-- Copy src to dst, but only if dst doesn't already exist
local function maybe_copy(src, dst)
	local out = io.open(dst)
	if out then
		out:close()
		return
	end

	local input = io.open(src, "r")
	if not input then
		return
	end

	out = io.open(dst, "w")
	if out then
		out:write(input:read("*a"))
		out:close()
	end
	input:close()
end

-- Maybe set current colours to defaults
maybe_copy(hypr .. "/scheme/default.lua", hypr .. "/scheme/current.lua")





-- Optional drop-in: probe before require so a missing user file never trips
-- Hyprland's config-error overlay. A present-but-broken file degrades via
-- pcall with a message instead of emergency mode (Ryoku optional() port).
local function optional(mod)
	if package.searchpath == nil or package.searchpath(mod, package.path) then
		local ok, err = pcall(require, mod)
		if not ok then
			print("hypr: optional module '" .. mod .. "' failed to load: " .. tostring(err))
		end
	end
end

-- Configs
require("modules.env")
require("modules.monitors")
require("modules.plugins")
require("modules.general")
require("modules.input")
require("modules.misc")
require("modules.animations")
require("modules.decoration")
require("modules.group")
require("modules.execs")
require("modules.rules")
require("modules.gestures")
require("modules.resize")
require("modules.lid")
require("modules.keybinds")
-- Power-saver strip after decoration so the profile wins; user.lua still wins.
require("modules.perf_saver")

-- Last word: ~/.config/hypr/user.lua, yours, never touched by updates.
optional("user")
