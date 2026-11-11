#!/usr/bin/env bash

STATE="$HOME/.config/waybar/monitor-brilho"
MONITOR=$(cat "$STATE" 2>/dev/null || echo "notebook")

case "$MONITOR" in
    lg)
        ATUAL=$(ddcutil --display 1 getvcp 10 --terse | awk '{print $4}')
        [[ "$ATUAL" =~ ^[0-9]+$ ]] || exit 1

        if [[ "$1" == "up" ]]; then
            NOVO=$((ATUAL + 5))
        else
            NOVO=$((ATUAL - 5))
        fi

        (( NOVO > 100 )) && NOVO=100
        (( NOVO < 0 )) && NOVO=0

        ddcutil --display 1 setvcp 10 "$NOVO"
        ;;
    *)
        if [[ "$1" == "up" ]]; then
            brightnessctl set 5%+
        else
            brightnessctl set 5%-
        fi
        ;;
esac
