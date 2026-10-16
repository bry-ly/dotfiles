# External Projects

Everything in this repo is configuration you authored or hand-tuned. These are
the **external git repositories** you had checked out in `~` that this repo does
*not* vendor — they're referenced here so you can re-create them on a new
machine with `./restore-projects.sh`.

They're excluded deliberately: several are large (`qylock` is 2.4G, mostly
rendered theme assets) and all of them already live on GitHub or the AUR.

---

## Summary

| Project | Source | Branch | Size | Local edits |
|---|---|---|---|---|
| `qylock` | [Darkkal44/qylock](https://github.com/Darkkal44/qylock) | `main` | 2.4G | yes |
| `ii-material-sddm` | [ToRvaLDz/ii-material-sddm](https://github.com/ToRvaLDz/ii-material-sddm) | `dev` | 3.8M | no |
| `matugen-theme-colorful` | [shreudi/vscode-matugen-theme](https://github.com/shreudi/vscode-matugen-theme) | `master` | 63M | yes |
| `matugen-theme-bridge` | [Grey-007/matugen-theme-bridge](https://github.com/Grey-007/matugen-theme-bridge) | `main` | 27M | yes |
| `disktree` | [tobi/disktree](https://github.com/tobi/disktree) | `main` | 3.9M | no |
| `MacTahoe-icon-theme` | [vinceliuice/MacTahoe-icon-theme](https://github.com/vinceliuice/MacTahoe-icon-theme) | `main` | 171M | no |
| `quickshell-git` | AUR `quickshell-git` | `master` | 2.2M | yes |
| `nvim` | [LazyVim/starter](https://github.com/LazyVim/starter) | `main` | 264K | yes |
| `matugen-themes` | [InioX/matugen-themes](https://github.com/InioX/matugen-themes) | `main` | — | no |

---

## ⚠️ Local edits not pushed anywhere

These changes exist **only** in your working tree. If you wipe the disk without
committing them, they are gone. Copy them out before reinstalling.

### `~/qylock` — `sddm.sh` (+17 lines)

```bash
git -C ~/qylock diff sddm.sh > ~/qylock-sddm-sh.patch
```

Also untracked: `themes-qt5/` (569M of Qt5 theme assets). Not in git, not
backed up. Recreate or preserve separately if you need it.

### `~/matugen-theme-colorful` — 3 modified source files

```bash
git -C ~/matugen-theme-colorful diff > ~/matugen-theme-colorful.patch
# package.json, src/extension.ts, src/template.ts
```

### `~/matugen-theme-bridge` — untracked `package-lock.json`

```bash
cp ~/matugen-theme-bridge/package-lock.json ~/matugen-theme-bridge-package-lock.json
```

### `~/quickshell-git` — modified `PKGBUILD`

```bash
git -C ~/quickshell-git diff PKGBUILD > ~/quickshell-git-PKGBUILD.patch
```

Untracked `quickshell/` is a build directory — discard it, `makepkg` rebuilds it.

### `~/.config/nvim` — modified config + 2 new files

```bash
git -C ~/.config/nvim diff > ~/nvim-config.patch
# modified: lua/config/options.lua
# new:      lazyvim.json, lua/plugins/transparency.lua
cp ~/.config/nvim/lazyvim.json ~/nvim-lazyvim.json
cp ~/.config/nvim/lua/plugins/transparency.lua ~/nvim-transparency.lua
```

---

## Restore

```bash
./restore-projects.sh          # clones all of the above into ~
./restore-projects.sh --patches  # also re-applies the .patch files
```

---

## Not projects — just data

| Path | What it is |
|---|---|
| `~/Android/Sdk` (1.1G) | Android SDK — reinstall via `android-sdk` |
| `~/backups/config-20260928-132408.tar.zst` (1G) | old config archive, ignore |
| `~/.config.bak/`, `~/.config-backup/` (58M, 33M) | stale config snapshots, ignore |
| `~/Downloads` (1.5G) | downloads, ignore |

---

## Where each project belongs after restore

```
~/qylock                    # hyprlock; ~/.config/hypr references it
~/ii-material-sddm          # SDDM login theme
~/matugen-theme-colorful    # VSCode matugen theme source (build with npm)
~/matugen-theme-bridge      # bridges matugen -> KDE/Qt
~/disktree                  # CLI disk usage tree; ~/.local/bin/disktree
~/MacTahoe-icon-theme       # icon theme
~/quickshell-git            # AUR build dir for quickshell-git
~/.config/nvim              # Neovim config (LazyVim)
~/.config/matugen/matugen-themes  # matugen scheme templates
```