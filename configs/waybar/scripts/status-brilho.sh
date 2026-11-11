#!/usr/bin/env bash

STATE="$HOME/.config/waybar/monitor-brilho"
MONITOR=$(cat "$STATE" 2>/dev/null || echo "notebook")

if [[ "$MONITOR" == "lg" ]]; then
    BRILHO=$(ddcutil --display 1 getvcp 10 --terse 2>/dev/null | awk '{print $4}')

    if [[ "$BRILHO" =~ ^[0-9]+$ ]]; then
        echo "{\"text\":\"☀\",\"tooltip\":\"LG UltraGear — Brilho: ${BRILHO}%\"}"
    else
        echo '{"text":"☀","tooltip":"LG UltraGear — Brilho indisponível"}'
    fi
else
    BRILHO=$(brightnessctl -m | awk -F, '{print $4}')

    echo "{\"text\":\"☀\",\"tooltip\":\"Notebook — Brilho: ${BRILHO}\"}"
fi
