#!/bin/bash
# Send focus-in/out events only to Claude pane, not all panes.
ACTIVE="$1"
while IFS=' ' read -r PANE CMD TTY; do
  [ "$CMD" = "claude" ] || continue
  if [ "$PANE" = "$ACTIVE" ]; then
    printf '\033[I' > "$TTY"
  else
    printf '\033[O' > "$TTY"
  fi
done < <(tmux list-panes -a -F "#{pane_id} #{pane_current_command} #{pane_tty}")
