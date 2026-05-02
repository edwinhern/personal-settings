# dotfiles-public

Personal macOS dotfiles, managed by [chezmoi](https://www.chezmoi.io/). Hostname-aware **personal** / **work** context with a one-time prompt fallback for unknown machines.

## Install

```sh
git clone https://github.com/edwinhern/dotfiles-public.git ~/Documents/github/dotfiles-public
cd ~/Documents/github/dotfiles-public
make install
```

`make install` is idempotent. It runs `scripts/install.sh`, which installs `chezmoi` via `https://get.chezmoi.io` if absent, then hands off to `chezmoi init --apply gh:edwinhern/dotfiles`. From there, `home/.chezmoiscripts/darwin/run_once_*` and `run_onchange_*` scripts install Homebrew, run `brew bundle`, run `mise install`, and install VS Code extensions.

After the first apply, `chezmoi apply` is self-completing: editing `home/.chezmoidata/packages.yaml` triggers `brew bundle` and the VS Code extension sync, and editing `home/dot_config/mise/config.toml.tmpl` triggers `mise install`. Each `run_onchange_*` script embeds a `sha256sum` of the file it watches, so chezmoi reruns it whenever that hash changes.

## Common commands

```sh
make apply             # chezmoi apply (re-render + run any onchange scripts)
make diff              # preview what apply would change
chezmoi add ~/.foo     # bring an existing file under management
chezmoi re-add         # pull live-edited files back into source state — use after an app rewrote its config
chezmoi edit ~/.foo    # edit the source-state version of a managed file
chezmoi status         # what would change vs source state
make fmt | make lint   # format / check shell, md, yaml, toml
make compile           # validate APM packages
```

`chezmoi re-add` is the most underrated command — it closes the loop when apps (Karabiner, VS Code, etc.) rewrite their own config files in place.

## Machine context

Known machines auto-classify by `LocalHostName` (`scutil --get LocalHostName` on darwin) — `edwinhern-personal-mac` is recognized as personal. Unknown hosts get a one-time prompt cached in `~/.config/chezmoi/chezmoi.toml`, never the repo. The prompt echoes the detected hostname, so onboarding a new machine never requires running `scutil` manually.

- Onboard another known personal machine: add an `else if eq $hostname "..."` branch in `home/.chezmoi.yaml.tmpl`. Look up the current hostname any time with `chezmoi data --format=json | jq -r .hostname`.
- Git name and email are prompted once per machine and cached locally — they never enter this public repo.
- The work hostname is intentionally not hardcoded; work machines fall through to the prompt.

## Local secrets

Secrets stay out of the repo. Each machine maintains its own `~/.secrets.local` (e.g. `export GITHUB_PERSONAL_ACCESS_TOKEN="…"`), and zsh sources it on shell start via the `[[ -f ~/.secrets.local ]] && source ~/.secrets.local` line in `home/dot_config/zsh/exports.zsh`. Never commit this file.

## References

- [chezmoi](https://www.chezmoi.io/) — dotfile manager
- [chezmoi macOS guide](https://www.chezmoi.io/user-guide/machines/macos/) — `sw_vers` + `defaults write` patterns
- [mise](https://mise.jdx.dev/) — runtime version manager
