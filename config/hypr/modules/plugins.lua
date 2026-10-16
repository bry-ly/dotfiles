-- Hyprland plugins.
--
-- hyprglass draws the blur itself: it renders a frosted decoration layer
-- *behind* any window that is transparent. Ghostty becomes transparent via
-- `background-opacity` in ~/.config/ghostty/config — that is the only half
-- Ghostty has to do. (Ghostty's own `background-blur` key is a no-op on
-- Hyprland, so it is deliberately left off.)
--
-- Enabled with: hyprpm enable hyprglass
-- Verify with:   hyprctl plugin list
--                hyprctl configerrors

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.config({
        default_theme = "dark",

        -- Withdraw Hyprland's own cached blur (`noblur`) on glassed windows.
        -- Without this, Hyprland's blur is captured before plugin decorations
        -- render, which hides the glass on static windows and makes the effect
        -- look like it only appears while dragging a window.
        manage_window_blur = true,

        -- Layer surfaces (bar, dock, notifications) are left off; the glass
        -- there is a separate opt-in via hg.layer(). Enable `layers` in
        -- hg.config() and whitelist namespaces if you want it.
        default_preset = "clean_blur",
    })

    -- A plain frosted blur.
    --
    -- The built-in presets (clear/subtle/glass/high_contrast) are all built
    -- around the liquid-glass look: lens distortion, refraction and chromatic
    -- aberration. Those are all zeroed below so the wallpaper reads as a soft
    -- blur rather than a distorted glass slab, which is what a terminal wants —
    -- any UV displacement behind text costs legibility.
    hg.preset("clean_blur", {
        -- 3.0 * 12.0 = 36px radius. Sits close to the `background-blur 40`
        -- that kitty.conf used before.
        blur_strength = 3.0,
        blur_iterations = 3,

        -- Opaque glass plate; transparency is Ghostty's job, via
        -- background-opacity. This only controls the decoration layer.
        glass_opacity = 1.0,

        -- Kill the glass optics.
        refraction_strength = 0.0,
        chromatic_aberration = 0.0,
        fresnel_strength = 0.0,
        specular_strength = 0.0,
        lens_distortion = 0.0,
        edge_thickness = 0.0,

        -- Dark slate tint, matched to Ghostty's default #14181f background
        -- family so the two layers agree. Raise the last byte for more tint.
        tint_color = 0x14181fb0,

        -- Tone mapping over the blurred wallpaper.
        brightness = 0.80,
        contrast = 0.95,
        saturation = 0.70,
        vibrancy = 0.0,
        -- Pulls bright areas (sky, highlights) down so light text stays
        -- readable over a bright wallpaper.
        adaptive_dim = 0.35,
    })
end
