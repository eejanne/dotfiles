#!/bin/bash
# Toggle Claude Code pane on/off to the right of neovim.

TRIGGERING_PANE=$(tmux display-message -p "#{pane_id}")
WINDOW=$(tmux display-message -p "#{window_id}")

# Use the stored pane ID — never search by command name, which would match
# any other claude session open in the same window.
CLAUDE_PANE=$(tmux show-option -gv @claude_pane_id 2>/dev/null)

# Verify the stored pane actually lives in this window right now.
if [ -n "$CLAUDE_PANE" ]; then
  tmux list-panes -t "$WINDOW" -F "#{pane_id}" | grep -q "^${CLAUDE_PANE}$" || CLAUDE_PANE=""
fi

if [ -n "$CLAUDE_PANE" ]; then
  # === HIDE ===
  NVIM_PANE=$(tmux show-option -gv @claude_nvim_pane 2>/dev/null)
  PRE_WIDTH=$(tmux show-option -gv @pre_claude_nvim_width 2>/dev/null)

  [ -n "$NVIM_PANE" ] && tmux select-pane -t "$NVIM_PANE"

  # Park Claude in a named background window so it can be rejoined later.
  tmux break-pane -d -s "$CLAUDE_PANE" -n claude

  # After break-pane, tmux naturally gives Claude's space to the adjacent pane.
  # Only resize if neovim is still narrower than its pre-Claude width, which
  # means a right-side pane took the space instead. Use -R (rightward only) so
  # left-side panes are never touched.
  if [ -n "$NVIM_PANE" ] && [ -n "$PRE_WIDTH" ]; then
    NEW_WIDTH=$(tmux display-message -p -t "$NVIM_PANE" "#{pane_width}")
    GROW=$((PRE_WIDTH - NEW_WIDTH))
    [ "$GROW" -gt 0 ] && tmux resize-pane -t "$NVIM_PANE" -R "$GROW"
  fi

  tmux set-option -gu @claude_pane_id
  tmux set-option -gu @claude_nvim_pane
  tmux set-option -gu @pre_claude_nvim_width

else
  # === SHOW ===
  NVIM_PANE="$TRIGGERING_PANE"

  tmux set-option -g @claude_nvim_pane "$NVIM_PANE"
  tmux set-option -g @pre_claude_nvim_width \
    "$(tmux display-message -p -t "$NVIM_PANE" "#{pane_width}")"

  CLAUDE_WINDOW=$(tmux list-windows -F "#{window_id} #{window_name}" \
    | awk '$2 == "claude" {print $1; exit}')

  if [ -n "$CLAUDE_WINDOW" ]; then
    SAVED_PANE=$(tmux list-panes -t "$CLAUDE_WINDOW" -F "#{pane_id}" | head -1)
    tmux join-pane -h -l 80 -s "$SAVED_PANE" -t "$NVIM_PANE"
    CLAUDE_PANE="$SAVED_PANE"
  else
    CLAUDE_PANE=$(tmux split-window -h -l 80 -P -F "#{pane_id}" -t "$NVIM_PANE" "claude")
  fi

  tmux set-option -g @claude_pane_id "$CLAUDE_PANE"
fi
