# Atalhos e personalizações

Os atalhos do ambiente são definidos principalmente em:

```text
configs/hypr/hyprland.lua
```

## Atalhos conhecidos

| Atalho | Ação |
|---|---|
| `Ctrl + Escape` | Mostrar ou ocultar a Waybar |
| `Super + Shift + S` | Capturar uma região da tela |

Outros atalhos devem ser consultados diretamente no arquivo `hyprland.lua`, que é a referência versionada.

## Terminal

O Kitty utiliza:

- `kitty.conf` — aparência e comportamento.
- `arch-startup.sh` — inicialização personalizada.
- `arch-dashboard.sh` — dashboard.
- `arch-dashboard.session` — layout de sessão.

## Waybar

Os scripts personalizados ficam em:

```text
configs/waybar/scripts/
```

Eles incluem controles de brilho, monitor, wallpaper e configurações.

## Prompt

O tema do Starship está em:

```text
configs/starship/starship.toml
```

## Listagem de arquivos

Script personalizado:

```text
configs/scripts/ls-home-colorido
```

O comportamento e os aliases associados devem ser consultados em `configs/bash/bashrc`.
