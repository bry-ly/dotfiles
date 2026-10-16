-- Lid-switch policy (Ryoku lid.lua port).
-- Laptops only: `switch:on:Lid Switch` fires on close, `switch:off` on open.
-- `locked = true` so the handoff works while the session is locked.
-- Single-panel default (you run eDP-1 only): close suspends, open re-lights.
-- Docked alternative (external monitor): replace the close command with
--   hl.dsp.dpms({ action = "off" })
-- to keep the session alive on the external output instead of suspending.
hl.bind(
	"switch:on:Lid Switch",
	hl.dsp.exec_cmd("systemctl suspend"),
	{ locked = true }
)
-- dpms is a dispatcher, not a shell command: the old
-- `hyprctl dispatch dpms on` form is rejected by 0.55+ parsers.
hl.bind(
	"switch:off:Lid Switch",
	hl.dsp.dpms({ action = "on" }),
	{ locked = true }
)
