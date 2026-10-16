# ~/.local/bin on PATH for every shell, not only interactive: tools dropped in
# there (claude, oh-my-posh) work. fish_add_path is idempotent.
if test -d $HOME/.local/bin
  fish_add_path $HOME/.local/bin
end

# point `go install` and `cargo install` at ~/.local/bin, and keep an existing
# editor choice.
set -gx GOBIN $HOME/.local/bin
set -gx CARGO_INSTALL_ROOT $HOME/.local
set -q EDITOR; or set -gx EDITOR nano
set -q VISUAL; or set -gx VISUAL nano

if status is-interactive
  set -g fish_greeting

  # Show CachyOS logo + system info
  command -v fastfetch &>/dev/null && fastfetch

  # Starship custom prompt
  command -v starship &>/dev/null && starship init fish | source

  # Direnv + Zoxide
  command -v direnv &>/dev/null && direnv hook fish | source
  command -v zoxide &>/dev/null && zoxide init fish | source

  # mise: shims + per-project tool versions. Not installed yet; the guard
  # keeps startup clean and it starts working the moment mise lands.
  command -v mise &>/dev/null && mise activate fish | source

  # Better ls
  command -v eza &>/dev/null && alias ls='eza --icons --group-directories-first -1'

  # Git
  abbr lg lazygit
  abbr gd 'git diff'
  abbr ga 'git add .'
  abbr gc 'git commit -am'
  abbr gl 'git log'
  abbr gs 'git status'
  abbr gst 'git stash'
  abbr gsp 'git stash pop'
  abbr gp 'git push'
  abbr gpl 'git pull'
  abbr gsw 'git switch'
  abbr gsm 'git switch main'
  abbr gb 'git branch'
  abbr gbd 'git branch -d'
  abbr gco 'git checkout'
  abbr gsh 'git show'

  # ls
  abbr l ls
  abbr ll 'ls -l'
  abbr la 'ls -a'
  abbr lla 'ls -la'

  # pacman (native)
  abbr p pacman
  abbr pu 'sudo pacman -Syu' # update system
  abbr ps 'pacman -Ss' # search
  # abbr pi 'sudo pacman -S' # install
  abbr pr 'sudo pacman -Rns' # remove + deps + configs
  abbr pq 'pacman -Qs' # query installed
  abbr po 'pacman -Qtdq | sudo pacman -Rns -' # remove orphans
  abbr pc 'sudo pacman -Scc' # clean cache
  abbr pl 'pacman -Ql' # list files owned by pkg
  abbr pinfo 'pacman -Si' # package info
  abbr pfile 'pacman -Qo' # which pkg owns file

  # yay (AUR)
  abbr ys 'yay -Ss' # search
  abbr yi 'yay -S' # install
  abbr yu 'yay -Yua' # update official + AUR
  abbr yr 'yay -Rns' # remove
  abbr yc 'yay -Yc' # clean
  abbr yq 'yay -Qs' # query

  # paru (AUR)
  abbr pu2 'paru -Sua' # update AUR
  abbr ps2 'paru -Ss' # search
  abbr pi2 'paru -S' # install

  # For jumping between prompts in foot terminal
  function mark_prompt_start --on-event fish_prompt
    echo -en "\e]133;A\e\\"
  end

end

# spicetify
fish_add_path /home/bryly/.spicetify

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Added by Antigravity CLI installer
set -gx PATH "/home/bryly/.local/bin" $PATH

# Android SDK
set -gx JAVA_HOME "$HOME/Android/jdk-17"
set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx ANDROID_SDK_ROOT "$HOME/Android/Sdk"
fish_add_path $JAVA_HOME/bin $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/emulator
