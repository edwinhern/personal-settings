# dotfiles-public

Personal macOS dotfiles, managed by [chezmoi](https://www.chezmoi.io/) with a single `context` switch for **work** vs **personal** machines.

## Install

```sh
git clone https://github.com/edwinhern/dotfiles-public.git ~/Documents/github/dotfiles-public
cd ~/Documents/github/dotfiles-public
make install
```

`make install` is idempotent. It installs Homebrew → `brew install mise` → uses `mise x chezmoi` ephemerally to run `chezmoi init --apply` → renders templates → `mise install` → `brew bundle`.

After the first apply, `chezmoi apply` is self-completing: editing `Brewfile.tmpl` triggers `brew bundle` automatically, editing `mise/config.toml.tmpl` triggers `mise install`, and a macOS update triggers any `defaults write` commands you've added (see `home/run_onchange_after_*.sh.tmpl`).

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

## Encrypted personal secrets

**Personal machines only.** The repo is public, so secrets travel age-encrypted with a passphrase-protected private key. Work machines opt out entirely (see below).

**One-time setup** (do this on your primary personal Mac, from the repo root):

```sh
REPO=~/Documents/github/dotfiles-public

# 1. Generate keypair, passphrase-encrypt the private key into the repo's source.
chezmoi age-keygen | chezmoi age encrypt --passphrase \
  --output="$REPO/home/key.txt.age"
# → prints "Public key: age1xxx..." Copy it.
# → prompts for passphrase twice. Save in Password manager.

# 2. Open home/.chezmoi.toml.tmpl. Replace the empty recipient with your key:
#       {{- $ageRecipient := "age1xxx..." -}}

# 3. Re-init chezmoi config so it picks up sourceDir + encryption block.
chezmoi init --prompt

# 4. Author the encrypted secrets file directly — no plaintext on disk.
TMP=$(mktemp -t secrets-XXXXX)
trap 'rm -P "$TMP" 2>/dev/null || rm -f "$TMP"' EXIT
$EDITOR "$TMP"        # paste: export GITHUB_PERSONAL_ACCESS_TOKEN="...", etc.
chezmoi encrypt --output \
  "$REPO/home/encrypted_private_dot_secrets.local.age" "$TMP"

# 5. Apply — decrypts to ~/.secrets.local automatically.
chezmoi apply
cat ~/.secrets.local  # sanity check

# 6. Commit and push.
cd "$REPO"
git add home/key.txt.age home/encrypted_private_dot_secrets.local.age home/.chezmoi.toml.tmpl
git commit -m "feat: enable age-encrypted personal secrets"
```

**On any other personal Mac:** clone the repo, run `make install`, type the passphrase once when prompted. `~/.secrets.local` materializes automatically, sourced by zsh.

## Work machine secrets

**Maintain `~/.secrets.local` by hand on the work machine.** Never commit it. The repo's encrypted personal blob is ignored on work via `home/.chezmoiignore.tmpl`, so the work machine never sees personal tokens. zsh's existing `[[ -f ~/.secrets.local ]] && source ~/.secrets.local` line picks up whatever you put there.

## References

- [chezmoi](https://www.chezmoi.io/) — dotfile manager
- [chezmoi encryption FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/) — first-time keygen pattern reference
- [chezmoi macOS guide](https://www.chezmoi.io/user-guide/machines/macos/) — `sw_vers` + `defaults write` patterns
- [mise](https://mise.jdx.dev/) — runtime version manager
