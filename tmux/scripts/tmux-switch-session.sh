#!/usr/bin/env bash

sessions=$(tmux list-sessions -F "#{session_name}")
choice=$(printf "%s\n" $sessions | fzf-tmux -p --reverse) || exit 0

if [[ -z "$choice" ]]; then
  exit 0
fi

tmux switch-client -t "$choice"
