# zsh exports (PATH, environment variables)

# User-installed binaries (chezmoi via get.chezmoi.io/lb, pipx, cargo, etc.)
export PATH="$HOME/.local/bin:$PATH"
# Ability to open editor in OpenCode
export EDITOR="code --wait"

# Personal: chezmoi decrypts ~/.secrets.local from age-encrypted source state.
# Work: maintain ~/.secrets.local by hand on the machine; never commit it.
# shellcheck source=/dev/null
[[ -f ~/.secrets.local ]] && source ~/.secrets.local
