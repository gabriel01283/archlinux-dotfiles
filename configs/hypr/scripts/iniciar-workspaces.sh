#!/usr/bin/env bash
set -euo pipefail

# Aguarda o Hyprland disponibilizar os monitores.
for i in $(seq 1 20); do
    if hyprctl monitors -j >/dev/null 2>&1; then
        break
    fi
    sleep 0.5
done

# Só configura o LG se ele estiver conectado.
hyprctl monitors -j | python3 -c '
import json, sys
sys.exit(0 if any(
    m["name"] == "HDMI-A-1"
    for m in json.load(sys.stdin)
) else 1)
' || exit 0

# Verifica se o LG já está usando um workspace próprio.
LG_WORKSPACE="$(hyprctl monitors -j | python3 -c '
import json,sys
for m in json.load(sys.stdin):
    if m["name"] == "HDMI-A-1":
        print(m["activeWorkspace"]["id"])
        break
')"

# Não interrompe uma sessão que já está nos workspaces 11–19.
if [[ "$LG_WORKSPACE" =~ ^1[1-9]$ ]]; then
    exit 0
fi

# Não interfere em workspaces que contenham janelas.
LG_WINDOWS="$(hyprctl workspaces -j | python3 -c '
import json,sys
ws=json.load(sys.stdin)
print(sum(w["windows"] for w in ws if w["monitor"]=="HDMI-A-1"))
')"

if (( LG_WINDOWS > 0 )); then
    exit 0
fi

# Guarda o monitor atualmente em foco.
ORIGINAL="$(hyprctl monitors -j | python3 -c '
import json,sys
print(next(
    (m["name"] for m in json.load(sys.stdin) if m.get("focused")),
    ""
))
')"

# Inicializa o LG no workspace 11.
hyprctl dispatch 'hl.dsp.focus({ monitor = "HDMI-A-1" })'
hyprctl dispatch 'hl.dsp.focus({ workspace = 11 })'

# Restaura o foco anterior.
if [[ -n "$ORIGINAL" && "$ORIGINAL" != "HDMI-A-1" ]]; then
    hyprctl dispatch "hl.dsp.focus({ monitor = \"$ORIGINAL\" })"
fi
