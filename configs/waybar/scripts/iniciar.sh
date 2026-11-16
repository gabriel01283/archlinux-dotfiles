#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/waybar/config.jsonc"
STATE="$HOME/.local/state/waybar/visibility"

if [[ "$(cat "$STATE" 2>/dev/null || echo visible)" == "hidden" ]]; then
    # A configuração agora é um array JSON.
    # Adiciona start_hidden a cada barra.
    exec waybar -c <(
        python3 - "$CONFIG" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    config = json.load(f)

for bar in config:
    bar["start_hidden"] = True

print(json.dumps(config))
PY
    )
else
    exec waybar -c "$CONFIG"
fi
