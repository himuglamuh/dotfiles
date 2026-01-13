#!/usr/bin/env bash
PANE_PID="$1"

# Get foreground process name + full args for this pane
cmd=$(ps -o comm= -p "$PANE_PID" 2>/dev/null || echo "")
full=$(ps -o args= -p "$PANE_PID" 2>/dev/null || echo "")

user=""
host=""

if [[ "$cmd" == "ssh" ]]; then
  # full might look like: ssh user@remotehost or ssh remotehost
  target=$(printf '%s\n' "$full" | awk '{print $NF}')

  if [[ "$target" == *@* ]]; then
    user="${target%@*}"
    host="${target#*@}"
  else
    user="$USER"
    host="$target"
  fi
else
  # Not ssh → show local user@host
  user="$(whoami)"
  host="$(hostname -s)"
fi

# Emit tmux-colored status text
printf '#[fg=#4DD6FF,bold]%s#[fg=white]@#[fg=#ff9900]%s ' "$user" "$host"
