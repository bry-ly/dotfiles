local vars = require("variables")

hl.config({
    general = {
        -- Single source: override via vars.layout ("dwindle" | "master" | "scrolling").
        layout          = vars.layout or "dwindle",

        allow_tearing   = false, -- Allows `immediate` window rule to work

        gaps_workspaces = vars.workspaceGaps,
        gaps_in         = vars.windowGapsIn,
        gaps_out        = vars.windowGapsOut,
        border_size     = vars.windowBorderSize,

        col             = {
            active_border   = vars.activeWindowBorderColour,
            inactive_border = vars.inactiveWindowBorderColour,
        },
    },

    dwindle = {
        preserve_split         = vars.dwindlePreserveSplit,
        smart_split            = vars.dwindleSmartSplit,
        smart_resizing         = vars.dwindleSmartResizing,
        split_width_multiplier = vars.dwindleSplitWidthMultiplier,
        default_split_ratio    = vars.dwindleDefaultSplitRatio,
    },

    master = {
        mfact          = vars.masterMfact,
        orientation    = vars.masterOrientation,
        new_status     = vars.masterNewStatus,
        new_on_top     = vars.masterNewOnTop,
        smart_resizing = vars.masterSmartResizing,
        drop_at_cursor = vars.masterDropAtCursor,
    },

    scrolling = {
        fullscreen_on_one_column = vars.scrollingFullscreenOneColumn,
        focus_fit_method         = vars.scrollingFocusFitMethod,
        column_width             = vars.scrollingColumnWidth or 0.5,
        follow_focus             = vars.scrollingFollowFocus,
        follow_min_visible       = 0.0,
        explicit_column_widths   = "0.35, 0.5, 0.65, 1.0",
    },
})
