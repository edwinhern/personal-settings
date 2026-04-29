# zsh aliases and small helper functions

alias o="open ."
alias l="ls"
alias ll="ls -al"
# shellcheck disable=SC2139 # ZDOTDIR is set at shell start; expand at alias define is fine
alias ozh='code ${ZDOTDIR:-$HOME}/.zshrc'
# shellcheck disable=SC2139
alias szh='source ${ZDOTDIR:-$HOME}/.zshrc'
alias kp="killport"
alias ".."="cd .."
alias update="brew update && brew upgrade && brew cleanup && mise upgrade"

killport() { kill -9 "$(lsof -t -i ":$1")"; }

update_homebrew() {
  command brew update --quiet
  command brew upgrade --quiet
  command brew upgrade --cask --greedy --quiet
  command brew cleanup --prune=all --quiet
}
