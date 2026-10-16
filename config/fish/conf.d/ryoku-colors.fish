# Ryoku palette for fish and fzf. Rendered by the theme daemon; do not edit.
#
# Dropped straight into conf.d, which fish sources on its own, so nothing in the
# shipped config has to include it. Your ~/.config/fish/user.fish loads last and
# still wins.

# Syntax highlighting.
set -g fish_color_normal e2e4d0
set -g fish_color_command a6d700
set -g fish_color_keyword a2d2a4
set -g fish_color_quote b6cea3
set -g fish_color_redirection c5c8b5
set -g fish_color_end a2d2a4
set -g fish_color_error ffb4ab
set -g fish_color_param e2e4d0
set -g fish_color_comment c5c8b5
set -g fish_color_selection --background=3a4d00
set -g fish_color_operator a2d2a4
set -g fish_color_escape b6cea3
set -g fish_color_autosuggestion c5c8b5
set -g fish_color_cancel ffb4ab
set -g fish_color_search_match --background=3a4d00
set -g fish_color_valid_path --underline

# Completion pager.
set -g fish_pager_color_progress c5c8b5
set -g fish_pager_color_prefix a6d700
set -g fish_pager_color_completion e2e4d0
set -g fish_pager_color_description c5c8b5
set -g fish_pager_color_selected_background --background=3a4d00

# fzf takes the same palette, so Ctrl-R and Ctrl-T match the terminal they open
# in. Appended to whatever options are already set rather than replacing them.
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
--color=fg:#e2e4d0,bg:-1,hl:#a6d700 \
--color=fg+:#e2e4d0,bg+:#3a4d00,hl+:#a6d700 \
--color=info:#b6cea3,prompt:#a6d700,pointer:#a2d2a4 \
--color=marker:#a2d2a4,spinner:#b6cea3,header:#c5c8b5 \
--color=border:#454839"
