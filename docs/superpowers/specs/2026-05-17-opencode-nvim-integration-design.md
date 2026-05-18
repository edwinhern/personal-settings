# Opencode Nvim Integration Design

**Status:** Approved for implementation.

**Issue:** [#32](https://github.com/edwinhern/dotfiles/issues/32)

## Goal

Connect LazyVim to a running OpenCode server while keeping tmux responsible for the editor and agent panes.

## Workflow

- Keep LazyVim in the left tmux pane.
- Start OpenCode in the right tmux pane with `opencode --port`.
- Use `opencode.nvim` from Neovim to send the current buffer or visual selection to the running OpenCode server.
- Keep terminal layout outside Neovim for now; Neovim should not create or manage the OpenCode terminal pane in this pass.

## Design

- Add `home/dot_config/nvim/lua/plugins/opencode.lua` as the LazyVim plugin spec.
- Install `nickjvandyke/opencode.nvim` through `lazy.nvim` with `version = "*"`.
- Load `opencode.nvim` at startup so `:checkhealth opencode` is available without a manual `:Lazy load` step.
- Set `vim.o.autoread = true` so buffers reload after OpenCode edits files.
- Keep `server.port = nil` so the plugin can discover the `opencode --port` server.
- Set `server.start`, `server.stop`, and `server.toggle` to `false` so `opencode.nvim` does not create a Neovim-managed OpenCode terminal.
- Hide the OpenCode server action from the generic select menu because `<leader>oS` handles server selection directly.
- Add the optional `folke/snacks.nvim` picker action because LazyVim already includes Snacks and the integration is recommended by `opencode.nvim`.
- Add LazyVim health-check tools `fd`, `fzf`, and `lazygit` to shared Homebrew formulas.
- Disable lazy.nvim rocks support because this config does not use LuaRocks plugins.

## Keymaps

- `<leader>oa`: ask OpenCode about the current buffer or visual selection with `@this`.
- `<leader>os`: select an OpenCode action.
- `<leader>oS`: select an OpenCode server when more than one server is running.
- `<leader>on`: start a new OpenCode session.

The keymaps avoid `<C-a>`, `<C-x>`, and terminal-toggle bindings because this repo uses tmux panes for layout and those control-key mappings conflict with normal editing habits.

## Verification

- `home/dot_config/nvim/lua/plugins/opencode.lua` exists.
- Start OpenCode in the right pane with `opencode --port` before using the Neovim integration.
- Open Neovim in the left pane with `nvim .`.
- Run `:Lazy` and confirm `opencode.nvim` is installed.
- Run `:checkhealth opencode` after plugin installation.
- Run `:checkhealth lazy` and confirm the unused LuaRocks warning is gone.
- Run `:checkhealth lazyvim` and confirm `fd`, `fzf`, and `lazygit` are available after Homebrew applies packages.
- `mise check` passes.
