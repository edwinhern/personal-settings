# LazyVim Opencode Terminal Design

**Status:** Approved for implementation.

**Issue:** [#30](https://github.com/edwinhern/dotfiles/issues/30)

## Goal

Add a minimal LazyVim-based Neovim source config that chezmoi can apply for terminal-first editing in this dotfiles repo.

## Scope

- Add Neovim to the shared Homebrew formulas.
- Keep LazyVim starter files directly under `home/dot_config/nvim/`.
- Do not track a nested LazyVim starter `.git` directory.
- Keep tmux unchanged for this pass because the existing config already enables mouse, vi copy mode, and terminal passthrough support.
- Defer `opencode.nvim` until the base Neovim config lands and the OpenCode server workflow is chosen.

## Design

The initial Neovim setup is the upstream LazyVim starter layout adapted to chezmoi source paths:

- `home/dot_config/nvim/init.lua` loads `lua/config/lazy.lua`.
- `home/dot_config/nvim/lua/config/lazy.lua` bootstraps `lazy.nvim`, imports `LazyVim/LazyVim`, and imports local plugin specs from `lua/plugins/`.
- `home/dot_config/nvim/lua/plugins/example.lua` remains disabled with an early empty return, preserving the starter examples without enabling extra plugins.
- `home/dot_config/nvim/stylua.toml` keeps formatting settings for Lua config.

## Deferred Work

Track `opencode.nvim` in a separate issue. That work should decide how the user starts OpenCode with a server port, which keymaps are useful, and whether `folke/snacks.nvim` should be used for the UI path.

## Verification

- `home/dot_config/nvim/init.lua` exists.
- No `home/dot_config/nvim/starter/` directory is present.
- No nested `home/dot_config/nvim/.git/` directory is tracked.
- Homebrew formulas include `neovim`.
- `mise check` passes.
