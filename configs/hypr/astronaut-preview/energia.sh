#!/usr/bin/env bash

ACAO="${1:-}"
SOCKET="${WAYLAND_DISPLAY:-principal}"
ESTADO="${XDG_RUNTIME_DIR:-/tmp}/astronaut-lofi-${UID}-${SOCKET}.state"
AGORA=$(date +%s)

nome_acao() {
    case "$1" in
        suspender) echo "suspender" ;;
        reiniciar) echo "reiniciar" ;;
        desligar) echo "desligar" ;;
    esac
}

if [[ "$ACAO" == "status" ]]; then
    if [[ -f "$ESTADO" ]]; then
        read -r ANTERIOR TEMPO < "$ESTADO"

        if (( AGORA - TEMPO <= 7 )); then
            if [[ "$ANTERIOR" == teste-* ]]; then
                echo "Prévia: botão testado"
            else
                echo "Clique novamente para $(nome_acao "$ANTERIOR")"
            fi
        fi
    fi
    exit 0
fi

case "$ACAO" in
    suspender|reiniciar|desligar) ;;
    *) exit 1 ;;
esac

# Segurança: não executar ações de energia durante
# os testes com o Hyprland aninhado.
if [[ "${ASTRONAUT_PREVIEW:-0}" == "1" ]] ||
   pgrep -f '^Hyprland --config .*/astronaut-preview/hyprland.lua$' >/dev/null; then
    printf 'teste-%s %s\n' "$ACAO" "$AGORA" > "$ESTADO"
    exit 0
fi

if [[ -f "$ESTADO" ]]; then
    read -r ANTERIOR TEMPO < "$ESTADO"

    if [[ "$ANTERIOR" == "$ACAO" ]] &&
       (( AGORA - TEMPO <= 7 )); then
        rm -f "$ESTADO"

        case "$ACAO" in
            suspender) exec /usr/bin/systemctl suspend ;;
            reiniciar) exec /usr/bin/systemctl reboot ;;
            desligar) exec /usr/bin/systemctl poweroff ;;
        esac
    fi
fi

printf '%s %s\n' "$ACAO" "$AGORA" > "$ESTADO"
