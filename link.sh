#!/usr/bin/env bash
# links all files in ~/dotfiles folder to their respective position

used=()
DOT=$(dirname $(realpath "$0"))

used+=('xmonad')
mkdir -p $HOME/.xmonad/
ln -sf $DOT/xmonad/xmonad.hs $HOME/.xmonad

used+=('home')
for f in $DOT/home/*; do
    ln -sf $f "$HOME/.$(basename $f)"
done

used+=('zsh')
ZSH=${ZDOTDIR:-$HOME}
mkdir -p $ZSH
for f in $DOT/zsh/*; do
    ln -sf $f "$ZSH/.$(basename $f)"
    ln -sf $f "$ZSH/.zprezto/runcoms/$(basename $f)"
done

used+=('vim')
mkdir -p $HOME/.vim
for f in $DOT/vim/*; do
    ln -sf $f "$HOME/.vim/$(basename $f)"
done

for d in $DOT/*; do
    to="$HOME/.config/$(basename $d)"

    # ignore folders in `used`
    if [[ -n $(grep $(basename $d) <<< $used) ]]; then
        continue
    fi

    ln -sfn "$d" "$to"
done
