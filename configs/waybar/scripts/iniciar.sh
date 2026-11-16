#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/waybar/config.jsonc"
STATE="$HOME/.local/state/waybar/visibility"

if [[ "$(cat "$STATE" 2>/dev/null || echo visible)" == "hidden" ]]; then
    exec waybar -c <(sed '1a\  "start_hidden": true,' "$CONFIG")
else
    exec waybar -c "$CONFIG"
fi
