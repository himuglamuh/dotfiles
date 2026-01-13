#!/usr/bin/env bash
exec >> /tmp/tmux-popup.log 2>&1
set -euxo pipefail

cd "$(tmux display -p -F "#{pane_current_path}")"

commit=$(git log --date=short --format="%C(green)%cd %C(auto)%h%d %s" --graph |
  fzf --tmux=right,95%,95% --ansi --reverse --header="Checkout commit" |
  grep -o "[0-9a-f]\{7,\}") || exit 0

[ -n "$commit" ] && git checkout "$commit"
