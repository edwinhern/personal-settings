# zsh exports (PATH, environment variables)

# Personal: chezmoi decrypts ~/.secrets.local from age-encrypted source state.
# Work: maintain ~/.secrets.local by hand on the machine; never commit it.
# shellcheck source=/dev/null
[[ -f ~/.secrets.local ]] && source ~/.secrets.local
