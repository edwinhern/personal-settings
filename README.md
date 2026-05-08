# github.com/edwinhern/dotfiles

Edwin's dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

## Install on a Mac

One command — installs `chezmoi` if missing, clones this repo, and applies it to `$HOME`:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply edwinhern
```

The bare `edwinhern` is chezmoi's GitHub shorthand — it expands to `https://github.com/edwinhern/dotfiles.git`. You'll be prompted for git name/email and (if the hostname is unfamiliar) personal vs work context.

Apply triggers `home/.chezmoiscripts/darwin/run_once_*` and `run_onchange_*` to install Homebrew, run `brew bundle`, run `mise install`, and install VS Code extensions.

After the first apply, `chezmoi apply` is self-completing: editing `home/.chezmoidata/packages.yaml` triggers `brew bundle` and the VS Code extension sync, and editing `home/dot_config/mise/config.toml.tmpl` triggers `mise install`. Each `run_onchange_*` embeds a `sha256sum` of the file it watches, so chezmoi reruns it whenever that hash changes.

## Working on this repo

These targets operate against the local clone (via `chezmoi --source $PWD`), so you can test edits without pushing:

```sh
make apply             # apply local source state to $HOME
make diff              # preview what apply would change
make fmt               # format shell, md, yaml, toml
make lint              # lint shell, md, yaml, toml
make compile           # validate APM packages
```

Day-to-day chezmoi commands (run from anywhere — they target `~/.local/share/chezmoi`):

```sh
chezmoi add ~/.foo     # bring an existing file under management
chezmoi re-add         # pull live-edited files back into source state — use after an app rewrote its config
chezmoi edit ~/.foo    # edit the source-state version of a managed file
chezmoi status         # what would change vs source state
```
