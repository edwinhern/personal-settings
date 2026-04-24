# Personal Settings

Dotfiles and tool configs, organized XDG-style.

## Layout

```txt
dotfiles-public/
├── .config/                 # tool configs (mirrors ~/.config/)
│   ├── asdf/                # user-level asdf config (placeholder)
│   ├── git/                 # git config
│   ├── homebrew/            # Brewfile for `brew bundle`
│   ├── tmux/                # tmux.conf
│   ├── vscode/              # VS Code user settings, keybindings, extensions list
│   └── zsh/                 # ZDOTDIR target: .zshrc, aliases, exports, plugins
├── .github/                 # CI workflows + composite actions
├── packages/                # APM packages (business, development)
├── scripts/                 # lint, format, compile, setup-plugins
├── .editorconfig
├── .plugin-versions         # asdf plugin sources (project-level, needed for APM build)
├── .tool-versions           # asdf tool pins (project-level, needed for APM build)
├── apm.yml                  # APM root manifest
└── makefile                 # `make fmt`, `make lint`, `make compile`
```

## Commands

```sh
make fmt       # format shell, Markdown, YAML
make lint      # shellcheck + shfmt (bash dialect) + prettier check
make compile   # validate APM packages
```

## References

- [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)
