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

  if [ ! -e "$source" ]; then
    echo "No repo path found: $repo_rel"
    return
  fi

  local comparison="$target"
  local empty_dir=""
  local status=0
  local -a diff_options=(-u)

  if [ -d "$source" ]; then
    diff_options=(-ruN)
    if [ ! -e "$target" ]; then
      empty_dir="$(mktemp -d)"
      comparison="$empty_dir"
    elif [ ! -d "$target" ]; then
      echo "Path type differs: $target is a file; $repo_rel is a directory" > "$diff_file"
      changes_needed=1
      echo "Wrote $(basename "$diff_file")"
      return
    fi
  elif [ -d "$target" ]; then
    echo "Path type differs: $target is a directory; $repo_rel is a file" > "$diff_file"
    changes_needed=1
    echo "Wrote $(basename "$diff_file")"
    return
  elif [ ! -e "$target" ]; then
    comparison=/dev/null
  fi

  diff "${diff_options[@]}" "$comparison" "$source" > "$diff_file" || status=$?
  if [ -n "$empty_dir" ]; then
    rmdir "$empty_dir"
  fi

  if [ "$status" -gt 1 ]; then
    echo "Failed to diff $target" >&2
    return "$status"
  elif [ ! -e "$target" ]; then
    changes_needed=1
    echo "New path: $target" >> "$diff_file"
    echo "Wrote $(basename "$diff_file") for new path $target"
  elif [ "$status" -eq 1 ]; then
    changes_needed=1
    echo "Wrote $(basename "$diff_file")"
  else
    rm "$diff_file"
  fi
}

install_file() {
  local repo_rel="$1"
  local target="$2"
  local source="$REPO/$repo_rel"

  if [ ! -e "$source" ]; then
    echo "No repo path found: $repo_rel"
    return
  fi

  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target.bak"
    cp -RP "$target" "$target.bak"
    rm -rf "$target"
  fi
  cp -RP "$source" "$target"
  echo "Installed $target"
}

refresh_file() {
  local repo_rel="$1"
  local target="$2"
  local source="$REPO/$repo_rel"

  if [ ! -e "$target" ]; then
    echo "No target path found: $target"
    return
  fi

  mkdir -p "$(dirname "$source")"
  rm -rf "$source"
  cp -RP "$target" "$source"
  echo "Refreshed $repo_rel"
}

rollback_file() {
  local repo_rel="$1"
  local target="$2"
  local backup="$target.bak"

  if [ ! -e "$backup" ] && [ ! -L "$backup" ]; then
    echo "No backup path found: $backup"
    return
  fi

  rm -rf "$target"
  mv "$backup" "$target"
  echo "Rolled back $target"
}

usage() {
  echo "Usage: ./manage.sh [--diff|--install|--refresh|--rollback]" >&2
}

declare -A files=(
  [".tmux.conf"]="$HOME/.tmux.conf"
  [".bashrc"]="$HOME/.bashrc"
  [".bash_profile"]="$HOME/.bash_profile"
  [".vimrc"]="$HOME/.vimrc"
  [".config/alacritty"]="$HOME/.config/alacritty"
  [".config/clocks"]="$HOME/.config/clocks"
  [".config/nvim"]="$HOME/.config/nvim"
  [".config/rex"]="$HOME/.config/nvim"
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
  --rollback)
    echo "Rolling back live paths from .bak files"
    action=rollback_file
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
