#!/usr/bin/env bash
# symbolically links all configuration files to their necessary position

used=()
DOT=$(dirname $(realpath "$0"))

used+=('xmonad')
mkdir -p $HOME/.xmonad
ln -sf $DOT/xmonad/xmonad.hs $HOME/.xmonad

used+=('home')
for f in $DOT/home/*; do
    ln -sf $f "$HOME/.$(basename $f)"
done

used+=('zsh')
ZSH=${ZDOTDIR:-$HOME}
mkdir -p $ZSH/.zprezto/runcoms
for f in $DOT/zsh/*; do
    ln -sf "$f" "$ZSH/.$(basename $f)"
    ln -sf "$f" "$ZSH/.zprezto/runcoms/$(basename $f)"
done

used+=('vim')
mkdir -p $HOME/.vim
for f in $DOT/vim/*; do
    ln -sf $f "$HOME/.vim/$(basename $f)"
done

mkdir -p $HOME/.config
for d in $DOT/*; do
    # ignore `used` folders
    [ -n $(grep $(basename $d) <<< $used) ] && continue
    [ ! -d $d ] && continue

    to="$HOME/.config/$(basename $d)"
    ln -sfn "$d" "$to"
done

for f in $DOT/config/*; do
    to="$HOME/.config"
    ln -sf "$f" "$to"
done
