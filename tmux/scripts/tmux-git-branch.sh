#!/usr/bin/env bash
exec >> /tmp/tmux-popup.log 2>&1
set -euxo pipefail

cd "$(tmux display -p -F "#{pane_current_path}")"

branch=$(git for-each-ref --sort=-committerdate \
  --format="%(refname:short)" refs/heads/ |
  fzf --tmux=right,95%,95% --reverse --ansi \
    --header="Checkout branch" \
    --preview="git log -n5 --oneline --color=auto {}") || exit 0

[ -n "$branch" ] && git checkout "$branch"
