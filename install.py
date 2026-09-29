#!/usr/bin/env python3
"""Install reviewed local files; no package installs, networking or auth changes."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--apply', action='store_true', help='write files (default: dry run)')
p.add_argument('--home', type=Path, default=Path.home(), help='target home, useful for testing')
a = p.parse_args()
root = Path(__file__).resolve().parent
home = a.home.expanduser().absolute()
backup = home / '.local/state/hamish-dev/backups' / datetime.datetime.now().strftime('%Y%m%dT%H%M%S%f')
records = []

def write(relative, data, mode=0o644, preserve=False):
    target = home / relative
    # Do not follow symlinks outside the requested home (including linked dotfiles).
    for ancestor in [target, *target.parents]:
        if ancestor == home.parent:
            break
        if ancestor.is_symlink():
            raise SystemExit('Refusing symlink target; merge manually: ' + str(target))
    old = target.read_bytes() if target.exists() else None
    if old == data:
        return
    if preserve and old is not None:
        print('MERGE MANUALLY (existing file kept):', relative)
        return
    print(('WRITE ' if a.apply else 'WOULD WRITE ')+str(relative))
    if a.apply:
        target.parent.mkdir(parents=True, exist_ok=True)
        if old is not None:
            saved = backup / relative
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target, saved)
        target.write_bytes(data)
        os.chmod(target, mode)
        records.append({'path':str(relative), 'previously_existed':old is not None})

def edit(relative, line, prepend=False, mode=0o644):
    target = home / relative
    old = target.read_text() if target.exists() else ''
    if line in old.splitlines():
        return
    value = line+'\n'+old if prepend else old+('' if not old or old.endswith('\n') else '\n')+line+'\n'
    write(relative, value.encode(), mode)

# Preflight every managed destination before making any change.
destinations = [Path('.zshrc'),Path('.ssh/config'),Path('.gitconfig')]
for source in (root/'payload').rglob('*'):
    if source.is_file():
        rel = source.relative_to(root/'payload')
        if rel.parts[0] == 'codex': dest = Path('.codex')/Path(*rel.parts[1:])
        elif rel.parts[0] == 'iterm2': dest = Path('Library/Application Support/iTerm2/DynamicProfiles/hamish-dev.json')
        else: dest = Path('.config/hamish-dev')/rel
        destinations.append(dest)
for rel in destinations:
    t = home/rel
    for parent in [t,*t.parents]:
        if parent == home.parent: break
        if parent.is_symlink(): raise SystemExit('Refusing symlink; merge manually: '+str(t))
    if t.exists() and not t.is_file(): raise SystemExit('Expected file: '+str(t))

for source in sorted((root/'payload').rglob('*')):
    if not source.is_file(): continue
    rel = source.relative_to(root/'payload')
    if rel.parts[0] == 'codex':
        dest = Path('.codex')/Path(*rel.parts[1:])
        write(dest,source.read_bytes(),preserve=True)
    elif rel.parts[0] == 'iterm2':
        write(Path('Library/Application Support/iTerm2/DynamicProfiles/hamish-dev.json'),source.read_bytes())
    else:
        write(Path('.config/hamish-dev')/rel,source.read_bytes(),0o600 if rel.parts[0]=='ssh' else 0o644)
edit(Path('.zshrc'),'source "$HOME/.config/hamish-dev/shell/dev.zsh"')
# Prepend because OpenSSH uses the first obtained value for most settings.
edit(Path('.ssh/config'),'Include ~/.config/hamish-dev/ssh/clusters.conf',prepend=True,mode=0o600)
# Compare the whole block to avoid duplicate multiline includes.
git = home/'.gitconfig'
block = '[include]\n    path = ~/.config/hamish-dev/git/config\n'
old = git.read_text() if git.exists() else ''
if block.strip() not in old:
    write(Path('.gitconfig'),(old+('' if not old or old.endswith('\n') else '\n')+block).encode())
if a.apply and records:
    os.chmod(home/'.ssh',0o700)
    backup.mkdir(parents=True,exist_ok=True)
    (backup/'changes.json').write_text(json.dumps(records,indent=2)+'\n')
    print('Backups and change manifest:',backup)
print('Done. Complete README.md steps for packages, Zinit, Codex merges and sign-in.')
