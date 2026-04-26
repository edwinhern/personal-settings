# dotfiles-public

Personal macOS dotfiles, managed by [chezmoi](https://www.chezmoi.io/) with a single `context` switch for **work** vs **personal** machines.

## Install

```sh
git clone https://github.com/edwinhern/dotfiles-public.git ~/Documents/github/dotfiles-public
cd ~/Documents/github/dotfiles-public
make install
```

`make install` is idempotent. It:

1. Installs Homebrew if missing.
2. `brew install mise` — the only dev tool brew owns directly.
3. Runs `chezmoi init --apply` (chezmoi pulled ephemerally via `mise x`). On first run, you'll be asked: **personal** or **work**.
4. `mise install` — installs the runtimes from the just-rendered `~/.config/mise/config.toml`.
5. `brew bundle` — installs the apps from the just-rendered `~/.config/homebrew/Brewfile`.

After this, chezmoi pins `chezmoi` itself in your mise config, so `chezmoi` is always available.

## Layout

```txt
dotfiles-public/
├── .chezmoiroot                       # points chezmoi at home/
├── home/                              # chezmoi source state
│   ├── .chezmoi.toml.tmpl             # one-time prompt: context = personal | work
│   ├── .chezmoidata/defaults.toml     # shared values (name, font, editor)
│   ├── .chezmoiignore.tmpl            # reserved
│   ├── dot_zshenv.tmpl                # exports ZDOTDIR=$HOME/.config/zsh
│   └── dot_config/
│       ├── git/config.tmpl            # [user.name] from defaults
│       ├── ghostty/config             # shared
│       ├── homebrew/Brewfile.tmpl     # shared + {personal|work} blocks
│       ├── mise/config.toml.tmpl      # shared runtimes + tinytex/ffmpeg gated to personal
│       ├── starship.toml              # shared
│       ├── tmux/tmux.conf             # shared
│       ├── vscode/                    # settings/keybindings/extensions
│       └── zsh/                       # .zshrc, aliases, exports, plugins
├── packages/                          # APM (agent package manager) packages
│   ├── business/                      # not currently driven by context
│   └── development/                   # personal AI agent setup
├── scripts/install.sh                 # bootstrap (called by `make install`)
├── mise.toml                          # project-level pins (apm, shellcheck, shfmt) for CI
├── apm.yml
└── makefile                           # fmt / lint / compile / install / apply / diff
```

## Layering model

```
              .chezmoidata/defaults.toml          (shared data: name, font, editor)
                          │
                          ▼
   chezmoi init  ─►  prompts "context" once  ─►  ~/.config/chezmoi/chezmoi.toml
                          │   (machine-local, not committed)
                          ▼
        templates render with .context = "personal" | "work"
                          │
        ┌─────────────────┴─────────────────┐
        ▼                                   ▼
  Brewfile (personal)                  Brewfile (work)
    + Discord, Aldente,                  + (placeholder; fill in
      Synology Drive, …                    when seeding work box)
  mise tools (personal)                mise tools (work)
    + tinytex, ffmpeg                    + (placeholder)
```

Same dotfiles either way. Only the **app/tool list** diverges; everything else (zsh, ghostty, tmux, vscode, starship, git) is shared.

## Adding a new tool / app

- **Tool** (mise-managed runtime): edit `home/dot_config/mise/config.toml.tmpl`. Put it in the shared `[tools]` block, or inside the `personal` / `work` conditional. Then `make apply && mise install`.
- **App** (homebrew cask or formula): edit `home/dot_config/homebrew/Brewfile.tmpl`. Same pattern. Then `make apply && brew bundle --file=~/.config/homebrew/Brewfile`.
- **Anything else** (shell config, editor settings, etc.): edit the relevant file under `home/dot_config/`. Then `make apply`.

`mise use -g <tool>` is **not** the workflow on a managed machine — chezmoi will overwrite the file. Treat the templates as the source of truth.

## Commands

```sh
make install   # full bootstrap (brew + mise + chezmoi + apply + bundle)
make apply     # re-run chezmoi apply against the current source
make diff      # show what `chezmoi apply` would change
make fmt       # format shell, Markdown, YAML
make lint      # shellcheck + shfmt + prettier
make compile   # validate APM packages
```

## References

- [chezmoi](https://www.chezmoi.io/) — dotfile manager
- [mise](https://mise.jdx.dev/) — runtime version manager (asdf-compatible)
- [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)
