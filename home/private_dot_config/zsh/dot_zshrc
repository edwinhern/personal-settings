# zsh main entry (sourced when ZDOTDIR=$HOME/.config/zsh)

# shellcheck source=/dev/null
source "${ZDOTDIR}/exports.zsh"
# shellcheck source=/dev/null
source "${ZDOTDIR}/aliases.zsh"

eval "$(mise activate zsh)"
eval "$(starship init zsh)"

# shellcheck source=/dev/null
source "${ZDOTDIR}/plugins.zsh"

if [[ -o interactive && "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
  fastfetch
fi
