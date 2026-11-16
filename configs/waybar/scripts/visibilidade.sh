#!/usr/bin/env bash
set -euo pipefail

STATE="$HOME/.local/state/waybar/visibility"
mkdir -p "$(dirname "$STATE")"

case "${1:-}" in
    toggle)
        if [[ "$(cat "$STATE" 2>/dev/null || echo visible)" == "hidden" ]]; then
            echo visible > "$STATE"
        else
            echo hidden > "$STATE"
        fi
        pkill -SIGUSR1 -x waybar || true
        ;;

    restore)
        if [[ "$(cat "$STATE" 2>/dev/null || echo visible)" == "hidden" ]]; then
            for i in {1..30}; do
                if pgrep -x waybar >/dev/null; then
                    sleep 0.3
                    pkill -SIGUSR1 -x waybar
                    exit 0
                fi
                sleep 0.1
            done
        fi
        ;;

    *)
        echo "Uso: $0 {toggle|restore}"
        exit 1
        ;;
esac
