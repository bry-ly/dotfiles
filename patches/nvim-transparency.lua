-- Transparency.
--
-- The active colourscheme is tokyonight (LazyVim's default is `moon`), not
-- Catppuccin -- Catppuccin is only installed as a fallback. tokyonight has one
-- `transparent` switch that stops it setting the background colour, which is the
-- supported way to do this.
--
-- Do NOT try `background = "NONE"` in options.lua instead: 'background' only
-- accepts dark|light, so it raises E474 and aborts the rest of that file.
--
-- With kitty at background_opacity 0.85 + background_blur, this lets the blurred
-- wallpaper show through the editor.

local M = {}

-- `transparent = true` only covers the base groups. These keep their own fills
-- regardless -- tokyonight hardcodes, for example:
--     CursorLine = { bg = c.bg_highlight }    (groups/base.lua)
--     StatusLine / NormalFloat / Pmenu = { bg = c.bg }
--
-- Clearing StatusLine/StatusLineNC is what makes lualine transparent too: its
-- `auto` theme finds no tokyonight-specific theme file, so it *generates* one by
-- reading these groups from the active colourscheme.
--
-- The Snacks* entries are the snacks picker/explorer chrome -- its floating
-- panels sit on NormalFloat, and these carry the remaining fills.
--
-- Deliberately NOT cleared: Visual (selection needs to stay visible),
-- SnacksPickerPickWin (accent), and the border groups, so windows stay
-- locatable against a busy wallpaper.
local GROUPS = {
  "CursorLine",
  "CursorLineSign",
  "CursorLineFold",
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "NormalFloat",
  "Pmenu",
  "PmenuSel",
  "PmenuKind",
  "PmenuExtra",
  "PmenuMatch",
  "SnacksPickerBoxTitle",
  "SnacksPickerInputTitle",
  "SnacksPickerInputBorder",
  "SnacksPickerList",
  "SnacksPickerListBorder",
  "SnacksPickerFooter",
  "SnacksPickerPreview",
  -- SnacksBackdrop is the dimming layer behind the picker (#000000). The
  -- profiler badges and the gh diff header are only used by those specific
  -- surfaces but default to opaque fills too.
  "SnacksBackdrop",
  "SnacksProfilerBadgeInfo",
  "SnacksProfilerBadgeTrace",
  "SnacksProfilerIconInfo",
  "SnacksProfilerIconTrace",
  "SnacksGhDiffHeader",
}

function M.apply()
  for _, g in ipairs(GROUPS) do
    if vim.fn.hlexists(g) == 1 then
      vim.api.nvim_set_hl(0, g, { bg = "NONE" })
    end
  end
end

-- Registered here at file scope, NOT inside a plugin spec's `init`. lazy.nvim
-- runs a spec `init` when that plugin loads, which for LazyVim/LazyVim is after
-- `:colorscheme` has already fired -- so the ColorScheme hook never ran.
local group = vim.api.nvim_create_augroup("user_transparency", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  desc = "Strip background fills the colourscheme re-applies",
  callback = M.apply,
})

-- ...but lazy.nvim can load this file *after* :colorscheme has already fired,
-- in which case the hook above never runs. VimEnter is the last thing before
-- the editor is usable, so re-apply there as well.
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  desc = "Catch a ColorScheme that fired before this file loaded",
  callback = M.apply,
})

-- The reliable one. tokyonight is lazy-loaded, so both hooks above can still be
-- early; `User VeryLazy` is lazy.nvim's own signal that startup is finished and
-- every plugin has had its turn at the highlight groups.
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "VeryLazy",
  desc = "Final pass once lazy.nvim has finished loading",
  callback = M.apply,
})

-- snacks derives its picker highlights when the picker opens, not on ColorScheme,
-- so it overwrites the strips above. Re-apply as its buffers come up.
-- Last resort. Logs show tokyonight re-applies its fills *after* every event
-- above during startup, so the winner is whoever writes last. A short deferred
-- pass runs once the dust has settled and wins by default.
vim.defer_fn(M.apply, 150)

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  group = group,
  pattern = { "snacks_picker_*", "snacks_explorer*" },
  callback = M.apply,
})

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
      transparent = true,
    },
    -- tokyonight is lazy-loaded and applies itself after VimEnter, so both
    -- event hooks above can still miss it. Doing setup + :colorscheme here means
    -- M.apply() runs immediately afterwards, which is deterministic.
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
      M.apply()
    end,
  },

  -- Catppuccin ships as the fallback colourscheme; make it transparent too so
  -- switching to it does not drop back to an opaque panel.
  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
      float = { transparent = true },
    },
  },
}