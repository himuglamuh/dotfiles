#!/usr/bin/env bash

set -euo pipefail

SEARCH_DIRS=("$HOME/git" "$HOME/personal" "$HOME/work")
PANE_ID=$(tmux display -p '#{pane_id}')

FILES=$(find "${SEARCH_DIRS[@]}" \
  -path '*/.git' -prune -o \
  -type f -printf '%T@ %p\n' 2>/dev/null |
  sort -nr | cut -d' ' -f2- | head -n 200 || true)

if [ -z "$FILES" ]; then
  exit 0
fi

MENU=$(echo "$FILES" | while read -r full; do
  label=$(echo "$full" | awk -F/ '{n=NF; print $(n-2) "/" $(n-1) "/" $n}')
  printf "%-40s\t%s\n" "$label" "$full"
done)

SELECTED=$(echo "$MENU" |
  fzf --prompt="Recent files > " \
      --preview="bat --style=numbers --color=always --line-range=:500 {2}" \
      --with-nth=1 \
      --delimiter="│" \
      --height=70% --layout=reverse \
      --tmux=right,95%,95%) || {
  exit 0
}

# Extract full path from the selected line
FULL_PATH=$(echo "$SELECTED" | cut -f2- | sed 's/^ *//')

if [ -z "$FULL_PATH" ]; then
  exit 0
fi

CMD="cd $(dirname "$FULL_PATH") && code-insiders $(basename "$FULL_PATH")"
tmux send-keys -t "$PANE_ID" "$CMD" C-m
