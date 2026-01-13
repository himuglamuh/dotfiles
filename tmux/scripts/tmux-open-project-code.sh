#!/usr/bin/env bash
set -euo pipefail

SEARCH_DIRS=("$HOME/git" "$HOME/personal" "$HOME/work")
PANE_ID=$(tmux display -p '#{pane_id}')
PROJECTS=$(find "${SEARCH_DIRS[@]}" -maxdepth 3 -mindepth 1 -type d 2>/dev/null || true)

if [ -z "$PROJECTS" ]; then
  exit 0
fi

SELECTED=$(echo "$PROJECTS" |
  fzf --prompt="Select a project > " \
      --preview="ls -la {}" \
      --tmux=right,95%,95%) || exit 0

if [ -z "$SELECTED" ]; then
  exit 0
fi

CMD="cd \"$SELECTED\" && code-insiders ."
tmux send-keys -t "$PANE_ID" "$CMD" C-m
