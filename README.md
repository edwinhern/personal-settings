# github.com/edwinhern/dotfiles

Edwin's dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

Install them with:

```console
$ chezmoi init edwinhern
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
