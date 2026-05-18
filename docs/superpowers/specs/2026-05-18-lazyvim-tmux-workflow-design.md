# LazyVim Tmux Workflow Design

**Status:** Approved for implementation.

**Issue:** [#37](https://github.com/edwinhern/dotfiles/issues/37)

## Goal

Make the daily LazyVim and tmux workflow easier to use by fixing selected health warnings, making copy and paste reliable, and adding a short cheatsheet.

## Scope

- Add shared Homebrew formulas for `nvim-treesitter` CLI support and Snacks image rendering checks.
- Add the Treesitter parsers reported by Snacks image health for docs and web filetypes.
- Send Neovim yanks to the macOS clipboard.
- Send tmux copy-mode yanks to the macOS clipboard through `pbcopy`.
- Enable tmux focus events for Neovim file change detection inside tmux.
- Document daily LazyVim navigation, hidden file toggles, tmux commands, copy/paste, and OpenCode usage.
- Leave optional provider warnings and which-key overlap warnings unchanged.

## Design

- `home/.chezmoidata/packages.yaml` adds `tree-sitter-cli`, `imagemagick`, `ghostscript`, `tectonic`, and `mermaid-cli` to shared Homebrew formulas.
- `home/dot_config/nvim/lua/plugins/treesitter.lua` extends LazyVim's `nvim-treesitter` `ensure_installed` list with `css`, `latex`, `norg`, `scss`, `svelte`, `typst`, and `vue`.
- `home/dot_config/nvim/lua/config/options.lua` sets `vim.opt.clipboard = "unnamedplus"` so normal and visual yanks use the macOS clipboard.
- `home/dot_config/tmux/tmux.conf` enables focus events and binds `y`, `Enter`, and mouse drag end in vi copy mode to `send -X copy-pipe-and-cancel "pbcopy"`.
- `.gitignore` ignores `.worktrees/` so project-local worktrees are not accidentally added.
- `docs/cheatsheets/lazyvim-tmux.md` is a short reference for this repo's LazyVim, tmux, and OpenCode workflow.

## Verification

- Package list contains the selected Homebrew formulas.
- Neovim Lua files parse with `luac -p` when available.
- tmux configuration parses with `tmux -f home/dot_config/tmux/tmux.conf start-server` when available.
- Markdown formatting passes through `mise check`.
- Full repo checks pass with `mise check`.
