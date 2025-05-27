eval "$(fnm env --use-on-cd --corepack-enabled --resolve-engines)"
source <(fzf --zsh)


export PATH=$PATH:$(go env GOPATH)/bin

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Homebrew
export HOMEBREW_NO_ENV_HINTS=true
export HOMEBREW_MAKE_JOBS=$(sysctl -n hw.ncpu)
export HOMEBREW_VERBOSE=true
export HOMEBREW_AUTO_UPDATE_SECS=3600
export HOMEBREW_BAT=true
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=14
export HOMEBREW_UPGRADE_GREEDY=true
brew() {
  if [[ $1 == bundle ]]; then # run bundle always with verbose
    shift 
    command brew bundle -v "$@"
  else
    command brew "$@"  
  fi
}
