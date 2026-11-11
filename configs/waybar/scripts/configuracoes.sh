#!/usr/bin/env bash

menu_conectividade() {
    local opcao

    opcao=$(printf '%s\n' \
        '󰖩  Rede' \
        '󰂯  Bluetooth' \
        '󰁍  Voltar' |
        rofi -dmenu -i -p "Conectividade" -theme "$HOME/.config/rofi/ocean-neon.rasi")

    case "$opcao" in
        *Rede)
            nm-connection-editor
            ;;
        *Bluetooth)
            blueman-manager
            ;;
        *Voltar)
            menu_principal
            ;;
    esac
}

menu_principal() {
    local opcao

    opcao=$(printf '%s\n' \
        '󰍹  Monitores' \
        '󰉼  Aparência' \
        '󰂚  Notificações' \
        '󰖩  Conectividade' \
        '󰕾  Áudio' \
        '󰏘  Tema Qt' |
        rofi -dmenu -i -p "Configurações" -theme "$HOME/.config/rofi/ocean-neon.rasi")

    case "$opcao" in
        *Monitores)
            nwg-displays
            ;;
        *Aparência)
            python "$HOME/.config/arch-login-editor/editor.py"
            ;;
        *Notificações)
            swaync-client -t
            ;;
        *Conectividade)
            menu_conectividade
            ;;
        *Áudio)
            pavucontrol
            ;;
        *Tema\ Qt)
            QT_QPA_PLATFORMTHEME=qt6ct qt6ct
            ;;
    esac
}

menu_principal
