#!/bin/bash
# Toggle Claude Code pane on/off to the right of neovim.
# Triggered via C-q; $TMUX_PANE is set by tmux to the neovim pane.

# TMUX_PANE is set by tmux (key binding) and inherited by neovim subprocesses.
NVIM_PANE="${TMUX_PANE}"
WINDOW=$(tmux display-message -p -t "$NVIM_PANE" "#{window_id}")

# Find a Claude pane visible in this window.
CLAUDE_PANE=$(tmux list-panes -t "$WINDOW" -F "#{pane_id} #{pane_current_command}" \
  | awk '$2 == "claude" {print $1; exit}')

if [ -n "$CLAUDE_PANE" ]; then
  # === HIDE ===
  tmux set-hook -gu after-select-pane
  tmux set -g focus-events off

  # Move cursor to neovim before removing Claude to avoid a visible jump.
  tmux select-pane -t "$NVIM_PANE"

  # Park Claude in a named background window so it can be rejoined later.
  tmux break-pane -d -s "$CLAUDE_PANE" -n claude

  # Restore neovim to its pre-Claude width.
  SAVED_WIDTH=$(tmux show-option -gv @pre_claude_nvim_width 2>/dev/null)
  if [ -n "$SAVED_WIDTH" ]; then
    tmux resize-pane -t "$NVIM_PANE" -x "$SAVED_WIDTH"
    tmux set-option -gu @pre_claude_nvim_width
  fi

  tmux set -g focus-events on
  tmux set-hook -g after-select-pane \
    'run-shell -b "~/dotfiles/tmux/claude-cursor.sh #{pane_id}"'

else
  # === SHOW ===
  tmux set-hook -gu after-select-pane
  tmux set -g focus-events off

  NVIM_WIDTH=$(tmux display-message -p -t "$NVIM_PANE" "#{pane_width}")
  tmux set-option -g @pre_claude_nvim_width "$NVIM_WIDTH"

  # Rejoin a parked Claude window if one exists, otherwise open fresh.
  CLAUDE_WINDOW=$(tmux list-windows -a -F "#{window_id} #{window_name}" \
    | awk '$2 == "claude" {print $1; exit}')

  if [ -n "$CLAUDE_WINDOW" ]; then
    SAVED_PANE=$(tmux list-panes -t "$CLAUDE_WINDOW" -F "#{pane_id}" | head -1)
    tmux join-pane -h -s "$SAVED_PANE" -t "$NVIM_PANE"
  else
    tmux split-window -h -t "$NVIM_PANE" "claude"
  fi

  # Keep focus in neovim; leave Claude on the right.
  tmux select-pane -t "$NVIM_PANE"

  tmux set -g focus-events on
  tmux set-hook -g after-select-pane \
    'run-shell -b "~/dotfiles/tmux/claude-cursor.sh #{pane_id}"'
fi
