#!/usr/bin/env bash

{
  tmux list-sessions -F "S:#{session_name}"
  tmux list-windows -a -F "W:#{session_name}:#{window_index}:#{window_name}"
  tmux list-panes -a -F "P:#{session_name}:#{window_index}.#{pane_index}:#{pane_current_command}@#{pane_current_path}"
} | fzf-tmux -p 95%,95% --reverse --ansi \
  --header='Jump to S/W/P' \
  --preview="echo {1} | sed 's/^[SWP]://' | cut -d ':' -f1,2 | xargs -r -I{} tmux capture-pane -p -t {} | head -100" \
  --preview-window=right:60% \
  --bind "enter:execute(echo {} > /tmp/tmux-fzf-target)+abort"

[ ! -s /tmp/tmux-fzf-target ] && exit

sel="$(cat /tmp/tmux-fzf-target)"
prefix="${sel%%:*}"
body="${sel#*:}"
spec="${body%% *}"

case "$prefix" in
  S) tmux switch-client -t "$spec" ;;
  W)
    session="${spec%%:*}"
    win="${spec#*:}"
    # 'win' currently contains "2:nvim"; strip the name:
    win_idx="${win%%:*}"
    tmux switch-client -t "$session" \; select-window -t "${session}:${win_idx}"
    ;;
  P) session="${spec%%:*}"
    winpane="${spec#*:}"
    win="${winpane%%.*}"; pane="${winpane#*.}"
    tmux switch-client -t "$session" \; select-window -t "${session}:${win}" \; select-pane -t "${session}:${win}.${pane}" ;;
esac

rm -f /tmp/tmux-fzf-target
