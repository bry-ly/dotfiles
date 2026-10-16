local vars = require("variables")

-- Wildcard fallback: any output without an explicit rule gets a sane mode.
-- Loaded before the explicit rules below, so explicit output rules win.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Explicit monitor (selection in variables.lua: monitorOutput/Mode/
-- Position/Scale/Vrr/Transform). Applies on `hyprctl reload`.
if vars.monitorOutput ~= nil and vars.monitorOutput ~= "" then
    hl.monitor({
        output    = vars.monitorOutput,
        mode      = vars.monitorMode or "preferred",
        position  = vars.monitorPosition or "auto",
        scale     = vars.monitorScale ~= nil and vars.monitorScale or 1,
        vrr       = vars.monitorVrr or 0,
        transform = vars.monitorTransform or 0,
    })
end

-- Extra monitors (applied in order). Example in variables.lua:
-- extraMonitors = {
--     { output = "HDMI-A-1", mode = "preferred", position = "auto-right", scale = 1 },
-- },
if type(vars.extraMonitors) == "table" then
    for _, m in ipairs(vars.extraMonitors) do
        if type(m) == "table" and m.output ~= nil and m.output ~= "" then
            hl.monitor({
                output    = m.output,
                mode      = m.mode or "preferred",
                position  = m.position or "auto",
                scale     = m.scale ~= nil and m.scale or 1,
                vrr       = m.vrr or 0,
                transform = m.transform or 0,
            })
        end
    end
end
