GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

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

brew() {
  if [[ $1 == bundle ]]; then
    local cur_dir=$PWD
    cd "$HOME" || return
    shift
    command brew bundle "$@"

    local emacs_formula target dest needs_copy=1
    emacs_formula=$(command brew list --formula | grep '^emacs-plus@' | sort -V | tail -n1)
    if [[ -n $emacs_formula ]]; then
      target="$(command brew --prefix "$emacs_formula")/Emacs.app"
      dest="/Applications/Emacs.app"

      if [[ -d $dest ]]; then
        local old_sum new_sum
        old_sum=$(md5 -q "$dest/Contents/MacOS/Emacs" 2>/dev/null || printf '%s' none)
        new_sum=$(md5 -q "$target/Contents/MacOS/Emacs" 2>/dev/null || printf '%s' diff)
        [[ $old_sum == $new_sum ]] && needs_copy=0
      fi

      if (( needs_copy )); then
        sudo rm -rf "$dest"
        if sudo cp -R "$target" "$dest"; then
          /usr/bin/mdimport "$dest" >/dev/null 2>&1
          printf "${GREEN}Emacs (%s) copied to /Applications${RESET}\n" "$emacs_formula"
        else
          printf "${RED}Failed to copy Emacs to /Applications${RESET}\n" >&2
        fi
      fi
    fi
    cd "$cur_dir" || return
  else
    command brew "$@"
  fi
}

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
