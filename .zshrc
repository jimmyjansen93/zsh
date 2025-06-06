eval "$(fnm env --use-on-cd --corepack-enabled --resolve-engines)"
source <(fzf --zsh)

export PATH="$PATH:$(go env GOPATH)/bin"

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

export PNPM_HOME="/Users/jimmyjansen/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

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
alias reload='source ~/.zshrc'

eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"
eval "$(direnv hook zsh)"

brew() {
  if [[ $1 == bundle ]]; then
    CUR_DIR=$(pwd)
    cd $HOME
    shift
    command brew bundle "$@"

    EMACS_FORMULA=$( /opt/homebrew/bin/brew list --formula | grep '^emacs-plus@' | sort -V | tail -n1 )
    TARGET="$(/opt/homebrew/bin/brew --prefix "$EMACS_FORMULA")/Emacs.app"
    DEST="/Applications/Emacs.app"

    needs_copy=true
    if [[ -d "$DEST" ]]; then
      old_sum=$(md5 -q "$DEST/Contents/MacOS/Emacs" 2>/dev/null || echo none)
      new_sum=$(md5 -q "$TARGET/Contents/MacOS/Emacs" 2>/dev/null || echo diff)
      [[ $old_sum == $new_sum ]] && needs_copy=false
    fi

    if $needs_copy; then
      sudo rm -rf "$DEST"
      if sudo cp -R "$TARGET" "$DEST"; then
        /usr/bin/mdimport "$DEST" >/dev/null 2>&1
        printf "\033[0;32mEmacs ($EMACS_FORMULA) copied to /Applications\033[0m\n"
      else
        printf "\033[0;31mFailed to copy Emacs to /Applications\033[0m\n" >&2
      fi
    fi
    cd $CUR_DIR
  else
    command brew "$@"
  fi
}

update() {
  local repos=(nvim aerospace sketchybar tmux ghostty starship karabiner zsh btop emacs brewfile)
  local config_dir="$HOME/.config"
  local updated_any=0

  if [ -f "$HOME/Brewfile" ]; then
    echo "Running brew bundle..."
    (cd "$HOME" && brew bundle > /dev/null 2>&1)
    echo "Brew cleanup"
    brew cleanup --prune=all -s
  fi

  for repo in "${repos[@]}"; do
    local dir="$config_dir/$repo"
    if [ ! -d "$dir/.git" ]; then
      continue
    fi

    cd "$dir"
    local changed=0
    if [ -n "$(git status --porcelain)" ]; then
      git add -A > /dev/null 2>&1
      git commit -m "chore: auto-update config" > /dev/null 2>&1 && changed=1
      echo "Commited changes for $repo"
    else
      echo "No updates for $repo"
    fi

    git fetch origin > /dev/null 2>&1
    if git rebase origin/main > /dev/null 2>&1; then
      if [ $changed -eq 1 ]; then
        echo "Pushing $repo"
        git push origin HEAD:main > /dev/null 2>&1
        echo "Updated $repo (committed, rebased, and pushed)"
        updated_any=1
      fi
    else
      echo "[WARN] Rebase failed for $repo, please resolve manually."
    fi

    cd - > /dev/null
  done

  if [ -f "$HOME/.zshrc" ]; then
    echo "Sourcing zshrc"
    reload_zshrc()
  fi

  if [ $updated_any -eq 0 ]; then
    echo "No config repos needed updating."
  else
    echo "Update complete."
  fi
}

tmux_send_to_all_panes() {
  for _pane in $(tmux list-panes -F '#P'); do
    tmux send-keys -t ${_pane} "$@" Enter
  done
}

reload_zshrc() {
  source ~/.zshrc
  tmux list-panes -F '#{pane_pid}' | xargs -n1 kill -USR1
  print -Pr '%F{green}[zshrc reloaded]%f'
}
TRAPUSR1() reload_zshrc()
