-- Power-saver compositor strip (Ryoku perf_saver port).
-- When the active power profile is `power-saver`, drop blur + shadow: the
-- heaviest per-frame GPU cost on an iGPU laptop. Checked at config load, so
-- changing profile takes effect on the next `hyprctl reload`.
-- Manual override: anything in user.lua still wins (it loads last).
local function power_saver_active()
	local h = io.popen("powerprofilesctl get 2>/dev/null")
	if not h then
		return false
	end
	local out = h:read("*a") or ""
	h:close()
	return out:match("power%-saver") ~= nil
end

if power_saver_active() then
	hl.config({
		decoration = {
			blur = { enabled = false },
			shadow = { enabled = false },
		},
	})
end
