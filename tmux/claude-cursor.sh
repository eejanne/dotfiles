#!/bin/bash
# Show or hide Claude's cursor based on whether it's the active pane.
# Focus events are sent via send-keys (stdin/input direction) so Claude's
# input framework receives them and suppresses cursor drawing while unfocused.
ACTIVE="$1"
CLAUDE_PANE=$(tmux show-option -gv @claude_pane_id 2>/dev/null)

[ -z "$CLAUDE_PANE" ] && exit 0

CLAUDE_TTY=$(tmux display-message -p -t "$CLAUDE_PANE" "#{pane_tty}" 2>/dev/null)
[ -z "$CLAUDE_TTY" ] && exit 0

if [ "$CLAUDE_PANE" = "$ACTIVE" ]; then
  tmux send-keys -t "$CLAUDE_PANE" -l $'\033[I'
  printf '\033[?25h' > "$CLAUDE_TTY"
else
  tmux send-keys -t "$CLAUDE_PANE" -l $'\033[O'
fi
