#!/usr/bin/env bash
set -euo pipefail

NUM="${1:?Informe o workspace}"
ACTION="${2:-focus}"

[[ "$NUM" =~ ^[1-9]$ ]] || exit 1

MONITOR="$(hyprctl monitors -j | python3 -c 'import json,sys; print(next((m["name"] for m in json.load(sys.stdin) if m.get("focused")), ""))')"

if [[ "$MONITOR" == "HDMI-A-1" ]]; then
    ID=$((NUM + 10))
else
    ID="$NUM"
fi

case "$ACTION" in
    focus)
        hyprctl dispatch "hl.dsp.focus({ workspace = $ID })"
        ;;
    move)
        hyprctl dispatch "hl.dsp.window.move({ workspace = $ID })"
        ;;
    *)
        exit 1
        ;;
esac
