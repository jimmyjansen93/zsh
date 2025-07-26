GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

export XDG_CONFIG_HOME="$HOME/.config"
export PNPM_HOME="$HOME/Library/pnpm"

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
export HOMEBREW_VERBOSE=true
export HOMEBREW_AUTO_UPDATE_SECS=3600
export HOMEBREW_BAT=true
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=14
export HOMEBREW_UPGRADE_GREEDY=true

alias ll='lsd -l'
alias la='lsd -la'
alias l='lsd'
alias ls='lsd'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias vi='nvim'
alias vim='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'
alias reload='reload_zshrc'

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
  local repos=(nvim aerospace sketchybar tmux ghostty starship karabiner zsh btop emacs brewfile borders)
  local config_dir="$HOME/.config"

  if [[ -f $HOME/Brewfile ]]; then
    printf "${BLUE}Running brew bundle...${RESET}\n"
    if (cd "$HOME" && brew bundle >/dev/null 2>&1 && brew upgrade >/dev/null 2>&1); then
      printf "${GREEN}brew bundle completed successfully${RESET}\n"
    else
      printf "${RED}brew bundle failed${RESET}\n" >&2
    fi

    printf "${BLUE}Brew cleanup...${RESET}\n"
    if brew bundle cleanup --force && brew cleanup --prune=all -s >/dev/null 2>&1; then
      printf "${GREEN}brew cleanup completed${RESET}\n"
    else
      printf "${YELLOW}brew cleanup encountered issues${RESET}\n" >&2
    fi
  fi

  printf "${BLUE}Reloading zshrc${RESET}\n"
  reload_zshrc

  for repo in "${repos[@]}"; do
    local dir="$config_dir/$repo"
    [[ -d $dir/.git ]] || continue

    (
      cd "$dir" || return
      if [[ -n $(git status --porcelain) ]]; then
        git add -A >/dev/null 2>&1
        git commit -m "chore: auto-update config" >/dev/null 2>&1 
      fi

      git fetch origin >/dev/null 2>&1
      if git rebase origin/main >/dev/null 2>&1; then
        printf "${BLUE}Pushing %s ...${RESET}\n" "$repo"
        if git push origin HEAD:main >/dev/null 2>&1; then
          printf "${GREEN}Updated %s (committed, rebased, and pushed)${RESET}\n" "$repo"
        else
          printf "${YELLOW}Push failed for %s${RESET}\n" "$repo" >&2
        fi
      else
        printf "${YELLOW}[WARN] Rebase failed for %s, please resolve manually.${RESET}\n" "$repo" >&2
      fi
    )
  done

  printf "${BLUE}Updating PNPM tools${RESET}\n"
  if pnpm update -g --latest >/dev/null 2>&1; then
    printf "${GREEN}PNPM tools updated${RESET}\n"
  else
    printf "${YELLOW}PNPM tools update failed${RESET}\n"
  fi

  printf "${BLUE}Updating GO tools${RESET}\n"
  if go-global-update >/dev/null 2>&1; then
    printf "${GREEN}GO tools updated${RESET}\n"
  else
    printf "${YELLOW}GO tools update failed${RESET}\n"
  fi

  printf "${BLUE}_______________________________${RESET}\n"
  printf "${GREEN}Update complete.${RESET}\n"
}

reload_zshrc() {
  source ~/.zshrc
  if command -v tmux >/dev/null 2>&1; then
    tmux list-panes -F '#{pane_pid}' | xargs -r -n1 kill -USR1
  fi
  print -Pr '%F{green}[zshrc reloaded]%f'
}

TRAPUSR1() {
  source ~/.zshrc
}
