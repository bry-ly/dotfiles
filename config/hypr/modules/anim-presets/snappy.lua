-- -----------------------------------------------------
-- Animations
-- name "Snappy"
-- Fast, low-latency, minimal overshoot. Based on community
-- snappy presets (NeKoRoSHELL compact + R7rainz fast).
-- -----------------------------------------------------

--------------------------------------------------------------------------------
-- Animation Master Switch
--------------------------------------------------------------------------------
hl.config({
    animations = {
        enabled = true,
    }
})

--------------------------------------------------------------------------------
-- Animation Curves (Bezier)
--------------------------------------------------------------------------------
hl.curve("snappy", { type = "bezier", points = { {0.15, 1.0}, {0.1, 1.0} } })
hl.curve("snappyOut", { type = "bezier", points = { {0.3, 0.0}, {0.8, 0.15} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1.0} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })

--------------------------------------------------------------------------------
-- Animation Rules
--------------------------------------------------------------------------------
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "snappyOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 1, bezier = "liner", style = "once" })
hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "snappy", style = "popin 90%" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "snappy", style = "popin 90%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "snappyOut", style = "popin 90%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "almostLinear" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 1, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "snappy", style = "slidevert" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 2, bezier = "snappy" })
