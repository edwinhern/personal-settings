# github.com/edwinhern/dotfiles

Edwin's dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

## Install on a Mac

One command — installs `chezmoi` to `~/.local/bin` if missing, clones this repo, and applies it to `$HOME`:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply edwinhern
```

The bare `edwinhern` is chezmoi's GitHub shorthand — it expands to `https://github.com/edwinhern/dotfiles.git`. You'll be prompted for git name/email and (if the hostname is unfamiliar) personal vs work context.

Apply triggers `home/.chezmoiscripts/darwin/run_once_*` and `run_onchange_*` to install Homebrew, run `brew bundle`, run `mise install`, and install VS Code extensions.

After the first apply, `chezmoi apply` is self-completing: editing `home/.chezmoidata/packages.yaml` triggers `brew bundle` and the VS Code extension sync, and editing `home/dot_config/mise/config.toml.tmpl` triggers `mise install`. Each `run_onchange_*` embeds a `sha256sum` of the file it watches, so chezmoi reruns it whenever that hash changes.

## Working on this repo

These tasks operate against the local clone (via `chezmoi --source $PWD`), so you can test edits without pushing:

```sh
mise update            # apply local source state to $HOME
mise diff              # preview what apply would change
mise format            # format shell, md, yaml, toml
mise lint              # lint shell, md, yaml, toml
mise test              # run bats tests
mise check             # lint + test
```

Repo tasks live in `mise.toml`.
