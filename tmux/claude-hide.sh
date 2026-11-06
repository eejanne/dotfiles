#!/bin/bash
# Hide the Claude pane: break it to a background window and restore the pre-Claude layout.
#
# $TMUX_PANE is set by tmux to the pane that triggered the key binding (Claude).
# We select neovim first so the physical cursor is already in the correct area
# before the pane removal happens, avoiding a visible cursor leap.

LAYOUT=$(tmux show-option -gv @claude_window_layout 2>/dev/null)
CLAUDE_PANE="$TMUX_PANE"
NVIM_PANE=$(tmux list-panes -F "#{pane_id}" | grep -v "^${CLAUDE_PANE}$" | head -1)

tmux set-hook -gu after-select-pane
tmux set -g focus-events off

# Move focus to neovim before removing Claude so the cursor doesn't have to
# travel from Claude's side of the screen to neovim's side mid-operation.
[ -n "$NVIM_PANE" ] && tmux select-pane -t "$NVIM_PANE"

# Break Claude specifically (not the now-active neovim pane).
tmux break-pane -d -s "$CLAUDE_PANE"

# Only restore layout for multi-pane saved layouts; single-pane windows
# fill correctly on their own and a redundant select-layout fires extra SIGWINCH.
case "$LAYOUT" in *\[*|*\{*) tmux select-layout "$LAYOUT" ;; esac

tmux set-option -gu @claude_window_layout
tmux set -g focus-events on
tmux set-hook -g after-select-pane 'run-shell -b "~/dotfiles/tmux/claude-cursor.sh #{pane_id}"'
