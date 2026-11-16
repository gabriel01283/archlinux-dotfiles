unalias ls 2>/dev/null || true

# Listagem de diretórios com emojis
ls() {
    if [[ $# -gt 0 && "$1" == -* ]]; then
        command ls "$@"
        return
    fi

    local dir="${1:-.}"
    if [[ ! -d "$dir" ]]; then
        command ls "$@"
        return
    fi

    local item name emoji
    local -a items

    shopt -s nullglob
    items=("$dir"/*)

    for item in "${items[@]}"; do
        name="${item##*/}"

        if [[ -d "$item" ]]; then
            case "${name,,}" in
                documentos|documents) emoji="📁" ;;
                downloads) emoji="📥" ;;
                imagens|images|pictures) emoji="🖼️" ;;
                music|música|musicas) emoji="🎵" ;;
                videos|vídeos) emoji="🎬" ;;
                projetos|projects|dev) emoji="💻" ;;
                python) emoji="🐍" ;;
                java) emoji="☕" ;;
                web|sites) emoji="🌐" ;;
                .config|config|configurações) emoji="⚙️" ;;
                games|jogos) emoji="🎮" ;;
                *) emoji="📂" ;;
            esac
            printf '%s  %s\n' "$emoji" "$name"
        else
            printf '📄  %s\n' "$name"
        fi
    done

    shopt -u nullglob
}
