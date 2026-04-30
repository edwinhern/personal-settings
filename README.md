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

**One-time setup** (run from the repo root — `cd` in first):

The piped form `chezmoi age-keygen | chezmoi age encrypt --passphrase --output=...` hides the public-key line on some chezmoi versions, leaving you with no recipient to paste. Use the two-step form below instead — it keeps the public key visible.

```sh
# 1. Generate keypair to a plaintext temp file (so the public key is visible).
TMPKEY=$(mktemp -t agekey-XXXXX)
chezmoi age-keygen --output="$TMPKEY"

# 2. Show the public key — the line starting "# public key:". Copy it.
grep '^# public key:' "$TMPKEY"
#  → e.g.  # public key: age1xxxxx...

# 3. Encrypt the keypair file with a passphrase, save into the repo.
chezmoi age encrypt --passphrase --output=home/key.txt.age "$TMPKEY"

# 4. Shred the plaintext intermediate.
rm -P "$TMPKEY" 2>/dev/null || rm -f "$TMPKEY"

# 5. Open home/.chezmoi.toml.tmpl. Replace the empty recipient with your key:
#       {{- $ageRecipient := "age1xxx..." -}}

# 6. Re-init so chezmoi.toml picks up sourceDir + the encryption block.
#    --source is required on this first run only; afterwards sourceDir is
#    baked into ~/.config/chezmoi/chezmoi.toml.
chezmoi init --prompt --source "$(pwd)"

# 7. Author the encrypted secrets file directly — no plaintext on disk.
TMP=$(mktemp -t secrets-XXXXX)
nano "$TMP"        # paste: export GITHUB_PERSONAL_ACCESS_TOKEN="...", etc.
chezmoi encrypt --output home/encrypted_private_dot_secrets.local.age "$TMP"
rm -P "$TMP" 2>/dev/null || rm -f "$TMP"

# 8. Apply — prompts for passphrase once, then materializes ~/.secrets.local.
chezmoi apply
cat ~/.secrets.local  # sanity check

# 9. Commit and push.
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
