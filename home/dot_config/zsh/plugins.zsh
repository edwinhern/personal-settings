# Plugins are cloned by chezmoi (see home/.chezmoiexternal.toml).

plugins_dir="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

# shellcheck source=/dev/null
source "$plugins_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
# shellcheck source=/dev/null
source "$plugins_dir/zsh-history-substring-search/zsh-history-substring-search.zsh"
# shellcheck source=/dev/null
source "$plugins_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# shellcheck source=/dev/null
source "$plugins_dir/zsh-transient-prompt/transient-prompt.plugin.zsh"

# Keybindings for history substring search (must be after syntax-highlighting)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
