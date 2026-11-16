#!/usr/bin/env bash
set -euo pipefail
umask 077
[[ $EUID -ne 0 ]] || { echo 'Não execute como root.' >&2; exit 1; }
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec python3 - "$ROOT" "$@" <<'PY'
import json, os, shutil, sys, tempfile, datetime
from pathlib import Path
root=Path(sys.argv[1]); args=sys.argv[2:]
home=Path.home(); backups=Path(os.environ.get('XDG_STATE_HOME',str(home/'.local/state')))/'archlinux-dotfiles/backups'
mapping={'hypr':'.config/hypr','waybar':'.config/waybar','kitty':'.config/kitty','rofi':'.config/rofi','nvim':'.config/nvim','fastfetch':'.config/fastfetch','Kvantum':'.config/Kvantum','qt6ct':'.config/qt6ct','swayosd':'.config/swayosd','xdg-desktop-portal':'.config/xdg-desktop-portal','systemd/user':'.config/systemd/user','starship/starship.toml':'.config/starship.toml','bash/bashrc':'.bashrc','bash/emoji-ls.sh':'.config/bash/emoji-ls.sh','scripts/ls-home-colorido':'.local/bin/ls-home-colorido'}
def die(msg): raise SystemExit('ERRO: '+msg)
def check_path(p):
    if not p.is_relative_to(home): die('Destino fora de HOME: '+str(p))
    for q in (p,*p.parents):
        if q==home.parent: break
        if q.is_symlink(): die('Link simbólico no destino: '+str(q))
def regular_files(base):
    if base.is_symlink(): die('Link na origem: '+str(base))
    if base.is_file(): return [base]
    if not base.is_dir(): die('Origem inexistente: '+str(base))
    result=[]
    for dirpath, dirs, files in os.walk(base,followlinks=False):
        for name in dirs+files:
            p=Path(dirpath)/name
            if p.is_symlink() or not (p.is_file() or p.is_dir()): die('Origem especial: '+str(p))
        result.extend(Path(dirpath)/name for name in files)
    return sorted(result)
def inventory():
    result=[]
    for src,dest in mapping.items():
        source=root/'configs'/src
        for f in regular_files(source):
            rel=f.relative_to(source) if source.is_dir() else Path('.')
            dst=home/dest/rel if source.is_dir() else home/dest
            check_path(dst)
            if dst.exists() and not dst.is_file(): die('Destino não é arquivo: '+str(dst))
            result.append((f,dst))
    if not result: die('Nenhum arquivo encontrado')
    return result
def save_json(p,obj):
    temp=p.with_suffix('.tmp'); temp.write_text(json.dumps(obj,indent=2,ensure_ascii=False)); os.replace(temp,p)
def safe_copy(src,dst,replace_home=False):
    dst.parent.mkdir(parents=True,exist_ok=True)
    raw=src.read_bytes()
    if replace_home and b'\0' not in raw:
        try: raw=raw.decode('utf-8').replace('/home/gabriel/',str(home).rstrip('/')+'/').encode('utf-8')
        except UnicodeDecodeError: pass
    fd,tmp=tempfile.mkstemp(prefix='.dotfiles-',dir=dst.parent)
    try:
        with os.fdopen(fd,'wb') as out: out.write(raw)
        os.chmod(tmp,src.stat().st_mode & 0o777)
        os.replace(tmp,dst)
    finally:
        if os.path.exists(tmp): os.unlink(tmp)
def restore(run):
    run=run.resolve(strict=True)
    if run.parent!=backups.resolve() or not run.name.startswith('run-'): die('Diretório de backup inválido')
    manifest=run/'manifest.json'
    if not manifest.is_file(): die('Manifesto ausente')
    data=json.loads(manifest.read_text())
    if data.get('version')!=2: die('Versão do manifesto incompatível')
    items=data['items']
    for item in items:
        dest=home/item['rel']; check_path(dest)
        if not item['rel'] or '..' in Path(item['rel']).parts: die('Caminho inválido no manifesto')
        if item['existed']:
            backup=run/'original'/item['rel']
            if not backup.is_file() or backup.is_symlink(): die('Backup incompleto: '+str(backup))
    for item in reversed(items):
        dest=home/item['rel']; check_path(dest)
        if item['existed']: safe_copy(run/'original'/item['rel'],dest)
        elif dest.exists(): dest.unlink()
        print('Restaurado:',item['rel'])
    print('Rollback concluído. Arquivos extras foram preservados.')
if len(args)==1 and args[0]=='--dry-run':
    files=inventory(); print('SIMULAÇÃO — nenhuma alteração realizada.\n')
    for src,dst in files: print(('ATUALIZAR' if dst.exists() else 'CRIAR   '),str(dst.relative_to(home)))
    print(f'\n{len(files)} arquivos; extras locais preservados. SDDM/keyd/pacotes não incluídos.')
elif len(args)==1 and args[0]=='--install':
    files=inventory(); backups.mkdir(parents=True,exist_ok=True)
    run=Path(tempfile.mkdtemp(prefix='run-',dir=backups))
    data={'version':2,'status':'preparing','items':[]}
    manifest=run/'manifest.json'; save_json(manifest,data)
    # Prepara todas as cópias de segurança antes de alterar qualquer destino.
    for src,dst in files:
        rel=str(dst.relative_to(home)); existed=dst.exists()
        if existed: safe_copy(dst,run/'original'/rel)
        data['items'].append({'rel':rel,'existed':existed})
    save_json(manifest,data)
    data['status']='installing'; save_json(manifest,data)
    print('Backup:',run)
    try:
        for src,dst in files:
            check_path(dst); safe_copy(src,dst,replace_home=True)
            print('Instalado:',dst.relative_to(home))
        data['status']='completed'; save_json(manifest,data)
    except Exception:
        print('Falha durante instalação. Tentando rollback...',file=sys.stderr)
        restore(run)
        raise
    print('Instalação concluída. Para reverter: ./install.sh --restore-backup',run)
elif len(args)==2 and args[0]=='--restore-backup':
    restore(Path(args[1]))
else:
    print('Uso: ./install.sh --dry-run | --install | --restore-backup CAMINHO_DO_BACKUP')
    sys.exit(2)
PY
