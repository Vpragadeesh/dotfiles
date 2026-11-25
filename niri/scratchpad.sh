#!/usr/bin/env bash
set -u

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_FILE="$STATE_DIR/niri-scratchpad-window-id"
mkdir -p "$STATE_DIR"

current_id=$(niri msg --json focused-window 2>/dev/null | jq -r '.id // empty')
cur_ws_idx=$(niri msg --json workspaces 2>/dev/null | jq -r '.[] | select(.is_focused) | .idx')
cur_ws_id=$(niri msg --json workspaces 2>/dev/null | jq -r '.[] | select(.is_focused) | .id')

scratch_id=$(cat "$STATE_FILE" 2>/dev/null || true)

scratch_ws_id=""
if [ -n "$scratch_id" ]; then
    scratch_ws_id=$(niri msg --json windows 2>/dev/null | jq -r --arg id "$scratch_id" '.[] | select((.id | tostring) == $id) | .workspace_id // empty')
fi

# 1. If the scratchpad pop-up is focused, hide it without switching workspaces
if [ -n "$scratch_id" ] && [ "$current_id" = "$scratch_id" ]; then
    niri msg action move-window-to-workspace --window-id "$scratch_id" --focus false "scratchpad"
    exit 0
fi

# 2. If the scratchpad window still exists, pull it to the current workspace as a floating pop-up
if [ -n "$scratch_ws_id" ]; then
    if [ "$scratch_ws_id" != "$cur_ws_id" ]; then
        niri msg action move-window-to-workspace --window-id "$scratch_id" --focus false "$cur_ws_idx"
    fi
    niri msg action move-window-to-floating --id "$scratch_id"
    niri msg action focus-window --id "$scratch_id"
    exit 0
fi

# 3. Otherwise, capture the focused window as the scratchpad and hide it
[ -z "$current_id" ] && exit 0
printf '%s' "$current_id" > "$STATE_FILE"
niri msg action move-window-to-floating --id "$current_id"
niri msg action move-window-to-workspace --window-id "$current_id" --focus false "scratchpad"
