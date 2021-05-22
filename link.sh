#!/usr/bin/env bash
# Links all files in ~/dotfiles folder to their respective position

DOT=$(dirname $(realpath "$0"))
ZSH=${ZDOTDIR:-$HOME}

mkdir -p $HOME/.xmonad/
ln -sf $DOT/xmonad/xmonad.hs $HOME/.xmonad

for f in $DOT/home/*; do
    ln -sf $f "$HOME/.$(basename $f)"
done

mkdir -p $ZSH
for f in $DOT/zsh/*; do
    ln -sf $f "$ZSH/.$(basename $f)"
    ln -sf $f "$ZSH/.zprezto/runcoms/$(basename $f)"
done

used=(zsh home xmonad)
for d in $DOT/*; do
    to="$HOME/.config/$(basename $d)"

    if [[ -n $(grep $(basename $d) <<< $used) ]]; then
        continue
    fi

    ln -sfn "$d" "$to"
done
