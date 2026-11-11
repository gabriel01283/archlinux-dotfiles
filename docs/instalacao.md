# Instalação e dependências

## Ambiente

Distribuição: Arch Linux
Compositor: Hyprland
Shell: Bash

## Componentes principais

Os seguintes executáveis foram identificados no ambiente original:

- hyprland
- hyprlock
- hyprpaper
- kitty
- waybar
- starship
- rofi
- sddm
- eza
- python
- grim
- slurp
- wl-copy
- brightnessctl
- swaync
- swayosd-server

`jq` não estava instalado na última verificação. Ele não foi confirmado como dependência obrigatória.

Outros pacotes, fontes, bibliotecas e serviços podem ser necessários dependendo do conteúdo das configurações.

## Diretórios de destino

| Origem no repositório | Destino no sistema |
|---|---|
| `configs/hypr/` | `~/.config/hypr/` |
| `configs/kitty/` | `~/.config/kitty/` |
| `configs/waybar/` | `~/.config/waybar/` |
| `configs/rofi/` | `~/.config/rofi/` |
| `configs/starship/starship.toml` | `~/.config/starship.toml` |
| `configs/bash/bashrc` | `~/.bashrc` |
| `configs/scripts/ls-home-colorido` | `~/.local/bin/ls-home-colorido` |
| `configs/sddm/10-astronaut-lofi.conf` | `/etc/sddm.conf.d/10-astronaut-lofi.conf` |
| `configs/sddm/astronaut-lofi/` | `/usr/share/sddm/themes/astronaut-lofi/` |

## Wallpapers

Os wallpapers do repositório devem ser colocados em:

```text
~/Imagens/Wallpapers/
```

Os arquivos de configuração atuais referenciam esse diretório.

## Observações

- Adapte caminhos absolutos `/home/gabriel/` ao nome do usuário de destino.
- Preserve as permissões executáveis dos scripts.
- Faça backup das configurações existentes antes de copiar arquivos.
- Não substitua configurações do SDDM sem conferir o tema e os caminhos.
- Não execute scripts desconhecidos sem ler seu conteúdo.

Consulte [Recuperação](recuperacao.md) antes de restaurar o ambiente.
