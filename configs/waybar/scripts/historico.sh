#!/usr/bin/env bash

selecionado=$(cliphist list | rofi -dmenu -i -p "Histórico")

if [[ -n "$selecionado" ]]; then
    printf '%s\n' "$selecionado" | cliphist decode | wl-copy
fi
