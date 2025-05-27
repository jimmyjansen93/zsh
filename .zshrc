eval "$(fnm env --use-on-cd --corepack-enabled --resolve-engines)"
source <(fzf --zsh)

export PATH="$PATH:$(go env GOPATH)/bin"

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

export HOMEBREW_NO_ENV_HINTS=true
export HOMEBREW_MAKE_JOBS=$(sysctl -n hw.ncpu)
export HOMEBREW_VERBOSE=true
export HOMEBREW_AUTO_UPDATE_SECS=3600
export HOMEBREW_BAT=true
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=14
export HOMEBREW_UPGRADE_GREEDY=true

brew() {
  if [[ $1 == bundle ]]; then
    shift
    command brew bundle "$@"

    EMACS_FORMULA=$( /opt/homebrew/bin/brew list --formula | grep -E '^emacs-plus@' | sort -V | tail -n1 )
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
  else
    command brew "$@"
  fi
}
