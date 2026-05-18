# Zsh CLI Tool Integration Design

**Status:** Approved for implementation.

**Issue:** [#35](https://github.com/edwinhern/dotfiles/issues/35)

## Goal

Wire the shared Homebrew CLI tools into zsh with small shell helpers that fit the current dotfiles layout.

## Scope

- Keep package declarations in `home/.chezmoidata/packages.yaml` as the source for installed tools.
- Initialize `zoxide` and `fzf` from `home/dot_config/zsh/dot_zshrc`.
- Use `fd` as the fzf file backend from `home/dot_config/zsh/exports.zsh`.
- Add only small aliases that remove repeated typing.
- Leave `tmux` and `ripgrep` as their normal commands for now.

## Design

- `home/dot_config/zsh/dot_zshrc` sources exports, aliases, then initializes `mise`, `starship`, `zoxide`, and `fzf` before loading zsh plugins.
- `home/dot_config/zsh/exports.zsh` sets `FZF_DEFAULT_COMMAND` to use `fd --type f --hidden --follow --exclude .git` and reuses it for `FZF_CTRL_T_COMMAND`.
- `home/dot_config/zsh/aliases.zsh` maps `find` to `fd` and adds `lg` for `lazygit`.
- `tmux` remains unaliased because pane/session commands are easier to understand explicitly while the workflow is still settling.
- `ripgrep` remains available as `rg`, its standard command name.

## Verification

- `home/dot_config/zsh/dot_zshrc` initializes `zoxide` and `fzf`.
- `home/dot_config/zsh/exports.zsh` uses `fd` for fzf file discovery.
- `home/dot_config/zsh/aliases.zsh` includes `find="fd"` and `lg="lazygit"`.
- `mise check` passes.
