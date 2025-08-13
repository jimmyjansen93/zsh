source "$HOME/.config/zsh/bin/colors"

export XDG_CONFIG_HOME="$HOME/.config"
export PNPM_HOME="$HOME/Library/pnpm"
export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer"

local path_dirs=(
  "$HOME/.cargo/bin"
  "$HOME/.nimble/bin"
  "$(go env GOPATH)/bin"
  "$PNPM_HOME"
  "$HOME/.local/bin"
  "$(brew --prefix llvm)/bin"
)
export PATH="${(j|:|)path_dirs}:$PATH"
unset path_dirs

eval "$(fnm env --use-on-cd --corepack-enabled --resolve-engines)"
source <(fzf --zsh)

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
export STARSHIP_LOG=error

export HOMEBREW_NO_ENV_HINTS=true
export HOMEBREW_MAKE_JOBS=$(sysctl -n hw.ncpu)
export HOMEBREW_VERBOSE=
export HOMEBREW_AUTO_UPDATE_SECS=3600
export HOMEBREW_BAT=true
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=14
export HOMEBREW_UPGRADE_GREEDY=true

alias ll='lsd -l'
alias la='lsd -la'
alias l='lsd'
alias ls='lsd'
alias vi='nvim'
alias vim='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"
command -v direnv  >/dev/null 2>&1 && eval "$(direnv hook zsh)"

source "$HOME/.config/zsh/bin/brew-wrapper"

update() {
  "$HOME/.config/zsh/bin/update" "$@"
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/jimmyjansen/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# bun completions
[ -s "/Users/jimmyjansen/.bun/_bun" ] && source "/Users/jimmyjansen/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
