#!/bin/zsh

# Signal handler for reloading zsh configuration
# This allows safe reloading via USR1 signal

TRAPUSR1() {
  source ~/.zshrc
}