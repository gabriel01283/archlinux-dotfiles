# Recuperação do ambiente Arch Linux

Este documento descreve um processo manual e conservador para restaurar as configurações.

## 1. Clonar o repositório

```bash
git clone git@github.com:gabriel01283/archlinux-dotfiles.git
cd archlinux-dotfiles
```

É necessário ter o Git e acesso SSH ao repositório, ou utilizar a URL HTTPS.

## 2. Fazer backup da instalação atual

Antes de restaurar qualquer arquivo, salve as configurações já existentes.

Exemplo:

```bash
mkdir -p "$HOME/backup-dotfiles"

cp -a "$HOME/.config/hypr" "$HOME/backup-dotfiles/" 2>/dev/null || true
cp -a "$HOME/.config/kitty" "$HOME/backup-dotfiles/" 2>/dev/null || true
cp -a "$HOME/.config/waybar" "$HOME/backup-dotfiles/" 2>/dev/null || true
```

Faça também backup das configurações de Rofi, Bash e Starship, se existirem.

## 3. Preparar as dependências

Instale os programas utilizados pelo ambiente. Consulte [Instalação](instalacao.md).

## 4. Adaptar caminhos

Algumas configurações utilizam `/home/gabriel/`.

Antes de restaurá-las em outro usuário, substitua os caminhos absolutos nas cópias que serão instaladas.

Verifique especialmente:

- Hyprland e Rofi.
- Hyprlock e seus ícones.
- Hyprpaper e wallpapers.
- Waybar e seus scripts.
- Kitty e seu dashboard.

## 5. Restaurar gradualmente

Restaure um componente por vez, começando por terminal, prompt e launcher.

Depois configure Hyprland, Waybar, Hyprpaper e Hyprlock.

Restaure o SDDM por último, pois uma configuração incorreta do gerenciador de login pode impedir o acesso gráfico normal.

## 6. Verificar permissões

Os scripts `.sh` e `ls-home-colorido` devem manter permissão de execução.

## 7. Validar

Antes de reiniciar o computador:

- Confira a sintaxe das configurações.
- Confirme que os arquivos e wallpapers existem.
- Teste os scripts individualmente.
- Verifique o funcionamento do Hyprland e da Waybar.
- Confirme que o tema do SDDM está completo.

## Importante

Este repositório é um backup de configurações, não uma imagem completa do sistema.

Ele não inclui automaticamente pacotes instalados, serviços, fontes, drivers, configurações de hardware ou dados pessoais.
