# LazyVim and tmux Cheatsheet

This is a daily reference for this dotfiles setup. In LazyVim, `<leader>` is the space key. In tmux, the default prefix is `<C-b>`.

## Daily Flow

1. Start a named tmux session: `tmux new -s dotfiles`
2. Open the repo in Neovim: `nvim .`
3. Split tmux to the right: `<C-b>%`
4. Run OpenCode in the right pane: `opencode --port`
5. In Neovim, send the current buffer or visual selection to OpenCode: `<leader>oa`

## Find Keys

| Action                    | Keys           |
| ------------------------- | -------------- |
| Show buffer-local keymaps | `<leader>?`    |
| Search all keymaps        | `<leader>sk`   |
| Open Lazy plugin UI       | `:Lazy`        |
| Open health report        | `:checkhealth` |
| Cancel a menu or mode     | `<Esc>`        |

## Files And Search

| Action                 | Keys                              |
| ---------------------- | --------------------------------- |
| Find files             | `<leader><space>` or `<leader>ff` |
| Find config files      | `<leader>fc`                      |
| Recent files           | `<leader>fr`                      |
| Search text in project | `<leader>/`                       |
| Search help            | `<leader>sh`                      |
| Search diagnostics     | `<leader>sd`                      |
| Git status             | `<leader>gs`                      |

## Hidden Dotfiles

LazyVim's picker does not use the shell `FZF_DEFAULT_COMMAND`. Dotfiles and ignored files are toggled inside the picker or explorer.

| Place            | Hidden files | Gitignored files |
| ---------------- | ------------ | ---------------- |
| File picker      | `Alt-h`      | `Alt-i`          |
| Explorer sidebar | `H`          | `I`              |

Examples in this repo include `home/.chezmoiscripts/`, `home/.chezmoiignore`, `home/.chezmoiexternal.yaml.tmpl`, and `home/.chezmoi.yaml.tmpl`. Chezmoi source names like `home/dot_zshenv` become dotfiles only after chezmoi applies them.

## Buffers And Windows

| Action                | Keys                                   |
| --------------------- | -------------------------------------- |
| Pick open buffers     | `<leader>,` or `<leader>fb`            |
| Split below           | `<leader>-`                            |
| Split right           | `<leader>\|`                           |
| Move between windows  | `<C-w>h`, `<C-w>j`, `<C-w>k`, `<C-w>l` |
| Delete current window | `<leader>wd`                           |
| Zoom current window   | `<leader>wm`                           |
| Window command helper | `<C-w><space>`                         |

## Copy From Neovim To OpenCode

`vim.opt.clipboard = "unnamedplus"` sends Neovim yanks to the macOS clipboard.

1. In Neovim visual mode, select text.
2. Press `y`.
3. Move to the OpenCode tmux pane.
4. Paste with `Cmd-v`.

## OpenCode From Neovim

These keymaps come from `home/dot_config/nvim/lua/plugins/opencode.lua`.

| Action                                         | Keys         |
| ---------------------------------------------- | ------------ |
| Ask OpenCode about current buffer or selection | `<leader>oa` |
| Select OpenCode action                         | `<leader>os` |
| Select OpenCode server                         | `<leader>oS` |
| Start a new OpenCode session                   | `<leader>on` |

## tmux Sessions

| Action               | Command or keys           |
| -------------------- | ------------------------- |
| New named session    | `tmux new -s dotfiles`    |
| Attach named session | `tmux attach -t dotfiles` |
| List sessions        | `tmux ls`                 |
| Detach from session  | `<C-b>d`                  |
| Rename session       | `<C-b>$`                  |

## tmux Panes

| Action             | Keys           |
| ------------------ | -------------- |
| Split right        | `<C-b>%`       |
| Split below        | `<C-b>"`       |
| Move between panes | `<C-b><arrow>` |
| Show pane numbers  | `<C-b>q`       |
| Move to next pane  | `<C-b>o`       |
| Zoom current pane  | `<C-b>z`       |
| Kill current pane  | `<C-b>x`       |

## tmux Windows

| Action                | Keys                      |
| --------------------- | ------------------------- |
| New window            | `<C-b>c`                  |
| Next window           | `<C-b>n`                  |
| Previous window       | `<C-b>p`                  |
| Jump to window number | `<C-b>0` through `<C-b>9` |
| Rename current window | `<C-b>,`                  |
| Kill current window   | `<C-b>&`                  |

## Copy From tmux To OpenCode

The tmux config uses vi copy mode and copies selections to the macOS clipboard with `pbcopy`.

| Action                            | Keys               |
| --------------------------------- | ------------------ |
| Enter copy mode                   | `<C-b>[`           |
| Move in copy mode                 | `h`, `j`, `k`, `l` |
| Start selection                   | `<Space>`          |
| Copy selection to macOS clipboard | `y` or `<Enter>`   |
| Paste into OpenCode               | `Cmd-v`            |

Mouse selection in tmux copy mode also copies to the macOS clipboard when the drag ends.

## Reload After Applying Dotfiles

| Config                | Command                                              |
| --------------------- | ---------------------------------------------------- |
| Reload tmux config    | `<C-b>:` then `source-file ~/.config/tmux/tmux.conf` |
| Reload zsh config     | `source ~/.config/zsh/.zshrc`                        |
| Restart Neovim config | close and reopen `nvim`                              |
