#!/usr/bin/env bash

CONFIG="$HOME/.config/hypr/hyprpaper.conf"
STATE="$HOME/.config/hypr/wallpapers"
mkdir -p "$STATE"

# Escolher imagem
IMAGEM=$(zenity --file-selection \
    --title="Escolher wallpaper" \
    --file-filter="Imagens | *.png *.jpg *.jpeg *.webp *.PNG *.JPG *.JPEG *.WEBP") || exit 0

[[ -f "$IMAGEM" ]] || exit 1

# Escolher monitor
DESTINO=$(zenity --list --radiolist \
    --title="Aplicar wallpaper" \
    --text="Onde deseja aplicar a imagem?" \
    --column="Selecionar" --column="Monitor" \
    TRUE "Ambos os monitores" \
    FALSE "Notebook" \
    FALSE "LG UltraGear" \
    --width=420 --height=280) || exit 0

# Recuperar escolhas anteriores
NOTEBOOK=$(cat "$STATE/notebook" 2>/dev/null)
LG=$(cat "$STATE/lg" 2>/dev/null)

case "$DESTINO" in
    "Ambos os monitores")
        NOTEBOOK="$IMAGEM"
        LG="$IMAGEM"
        ;;
    "Notebook") NOTEBOOK="$IMAGEM" ;;
    "LG UltraGear") LG="$IMAGEM" ;;
    *) exit 0 ;;
esac

# Gerar configuração
TEMP=$(mktemp)
printf 'splash = false\n\n' > "$TEMP"

if [[ -f "$NOTEBOOK" ]]; then
    printf 'wallpaper {\n    monitor = eDP-1\n    path = %s\n    fit_mode = cover\n}\n\n' "$NOTEBOOK" >> "$TEMP"
fi

if [[ -f "$LG" ]]; then
    printf 'wallpaper {\n    monitor = HDMI-A-1\n    path = %s\n    fit_mode = cover\n}\n' "$LG" >> "$TEMP"
fi

# Preservar configuração anterior
if [[ -f "$CONFIG" ]]; then
    cp "$CONFIG" "$CONFIG.bak"
fi

mv "$TEMP" "$CONFIG"

printf '%s' "$NOTEBOOK" > "$STATE/notebook"
printf '%s' "$LG" > "$STATE/lg"

# Aplicar sem reiniciar o Hyprland
pkill -x hyprpaper 2>/dev/null || true
nohup hyprpaper >/tmp/hyprpaper.log 2>&1 </dev/null &

zenity --info --title="Wallpaper" \
    --text="Wallpaper configurado!"
