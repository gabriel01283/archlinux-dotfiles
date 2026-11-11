#!/usr/bin/env bash

STATE="$HOME/.config/waybar/monitor-brilho"

opcao=$(printf 'Notebook\nLG UltraGear' | rofi -dmenu -p "Controlar brilho")

case "$opcao" in
    "Notebook")
        echo "notebook" > "$STATE"
        ;;
    "LG UltraGear")
        echo "lg" > "$STATE"
        ;;
esac
