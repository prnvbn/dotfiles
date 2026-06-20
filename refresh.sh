#!/usr/bin/env bash

set -e

DEST="$(pwd)"

echo "Backing up configs to: $DEST"

# tmux
if [ -f "$HOME/.tmux.conf" ]; then
  cp "$HOME/.tmux.conf" "$DEST/.tmux.conf"
  echo "Copied tmux.conf"
else
  echo "No ~/.tmux.conf found"
fi

# shell config (bash or zsh fallback)
if [ -f "$HOME/.bashrc" ]; then
  cp "$HOME/.bashrc" "$DEST/.bashrc"
  echo "Copied bashrc"
else
  echo "No shell rc found"
fi

# alacritty
ALACRITTY_SRC="$HOME/.config/alacritty/alacritty.toml"

if [ -f "$ALACRITTY_SRC" ]; then
  mkdir -p "$DEST/.config/alacritty"
  cp "$ALACRITTY_SRC" "$DEST/.config/alacritty/alacritty.toml"
  echo "Copied alacritty.toml"
else
  echo "No alacritty.toml found"
fi

echo "Done."
