#!/usr/bin/env bash

set -e

if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
  if [ -x /opt/homebrew/bin/bash ]; then
    exec /opt/homebrew/bin/bash "$0" "$@"
  fi

  echo "manage.sh requires Bash 4.3 or newer" >&2
  exit 1
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIFF_DIR="$REPO/diffs"

write_diff() {
  local repo_rel="$1"
  local target="$2"
  local source="$REPO/$repo_rel"
  local diff_file="$DIFF_DIR/${repo_rel//\//__}.diff"

  if [ ! -f "$source" ]; then
    echo "No repo file found: $repo_rel"
    return
  fi

  if [ -f "$target" ]; then
    if diff -u "$target" "$source" > "$diff_file"; then
      rm "$diff_file"
    else
      local status=$?
      if [ "$status" -eq 1 ]; then
        changes_needed=1
        echo "Wrote $(basename "$diff_file")"
      else
        echo "Failed to diff $target" >&2
        return "$status"
      fi
    fi
  else
    if diff -u /dev/null "$source" > "$diff_file"; then
      rm "$diff_file"
    else
      local status=$?
      if [ "$status" -eq 1 ]; then
        changes_needed=1
        echo "Wrote $(basename "$diff_file") for new file $target"
      else
        echo "Failed to diff $target" >&2
        return "$status"
      fi
    fi
  fi
}

install_file() {
  local repo_rel="$1"
  local target="$2"
  local source="$REPO/$repo_rel"

  if [ ! -f "$source" ]; then
    echo "No repo file found: $repo_rel"
    return
  fi

  mkdir -p "$(dirname "$target")"
  cp "$source" "$target"
  echo "Installed $target"
}

refresh_file() {
  local repo_rel="$1"
  local target="$2"
  local source="$REPO/$repo_rel"

  if [ ! -f "$target" ]; then
    echo "No target file found: $target"
    return
  fi

  mkdir -p "$(dirname "$source")"
  cp "$target" "$source"
  echo "Refreshed $repo_rel"
}

usage() {
  echo "Usage: ./manage.sh [--diff|--install|--refresh]" >&2
}

declare -A files=(
  [".tmux.conf"]="$HOME/.tmux.conf"
  [".bashrc"]="$HOME/.bashrc"
  [".bash_profile"]="$HOME/.bash_profile"
  [".vimrc"]="$HOME/.vimrc"
  [".config/alacritty/alacritty.toml"]="$HOME/.config/alacritty/alacritty.toml"
  [".config/starship.toml"]="$HOME/.config/starship.toml"
  [".vscode/keybindings.json"]="$HOME/Library/Application Support/Code/User/keybindings.json"
  [".vscode/settings.json"]="$HOME/Library/Application Support/Code/User/settings.json"
  [".zed/keymap.json"]="$HOME/.config/zed/keymap.json"
  [".zed/settings.json"]="$HOME/.config/zed/settings.json"
)

mode="${1:---diff}"

if [ "$#" -gt 1 ]; then
  usage
  exit 1
fi

case "$mode" in
  --diff)
    rm -rf "$DIFF_DIR"
    mkdir -p "$DIFF_DIR"
    echo "Writing diffs to: $DIFF_DIR"

    changes_needed=0
    action=write_diff
    ;;
  --install)
    echo "Installing repo configs into live paths"
    action=install_file
    ;;
  --refresh)
    echo "Refreshing repo configs from live paths"
    action=refresh_file
    ;;
  *)
    usage
    exit 1
    ;;
esac

for repo_rel in "${!files[@]}"; do
  "$action" "$repo_rel" "${files[$repo_rel]}"
done

if [ "$mode" = "--diff" ] && [ "$changes_needed" -eq 0 ]; then
  echo "No changes needed"
fi

echo "Done."
