-- Keyboard resize mode (Ryoku resize.lua port).
-- SUPER+R enters an exclusive submap: bare arrows/hjkl resize the active
-- window without fighting the global SUPER+arrow focus binds.
-- Esc, Return, or SUPER+R again exits back to the normal keymap.
local step = 40

hl.define_submap("resize", function()
	hl.bind("Left", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
	hl.bind("Right", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true })
	hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
	hl.bind("Down", hl.dsp.window.resize({ x = 0, y = step, relative = true }), { repeating = true })
	hl.bind("h", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
	hl.bind("l", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true })
	hl.bind("k", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
	hl.bind("j", hl.dsp.window.resize({ x = 0, y = step, relative = true }), { repeating = true })
	hl.bind("Escape", hl.dsp.submap("reset"))
	hl.bind("Return", hl.dsp.submap("reset"))
	hl.bind("SUPER + R", hl.dsp.submap("reset"))
end)
