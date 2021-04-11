# Preserve tmux sessions
if [[ $DISPLAY ]]; then
    # if not running interactively: don't do anything.
  [[ $- != *i* ]] && return

  if [[ -z "$TMUX" ]]; then
    detached="$( tmux ls 2> /dev/null | grep -vm1 attached | cut -d: -f1 )"
    attached="$(tmux ls 2> /dev/null |  cut -d: -f1)"

    if [[ "$attached" = "Main" ]]; then
      tmux new-session
    elif [[ "$detached" = "Main" ]]; then
      tmux attach-session -t "$detached"
    else
      tmux new-session -s "Main" -n "main"
    fi
  fi
fi

# Prompt
[[ $IN_NIX_SHELL ]] || neofetch
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

fpath=(~/.stripe $fpath)
autoload -Uz compinit && compinit -i

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# To customize prompt, run `p10k configure` or edit ~/dev/dotfiles/.p10k.zsh.
[[ ! -f ~/dev/dotfiles/.p10k.zsh ]] || source ~/dev/dotfiles/.p10k.zsh

autoload -Uz promptinit
promptinit
prompt powerlevel10k

# Exports
# export CLASSPATH=$CLASSPATH:"$HOME/dev/coursera/algorithms/algs4/algs4.jar"
export FZF_DEFAULT_OPTS='--cycle'
export FZF_DEFAULT_COMMAND='/usr/bin/fd --type f'
export GOPATH=$HOME/go
export BAT_CONFIG=$HOME/.config/bat/config
# export ANDROID_SDK="$HOME/Android/Sdk"
# export ANDROID_SDK=$HOME/dev/Android/Sdk
export PATH=$PATH:$HOME/Android/Sdk/platform-tools
export PATH=$PATH:$GOPATH/bin

# Fix prompt spacing
# `set | grep _POWERLEVEL9K` to view all exported settings
# export POWERLEVEL9K_LEFT_SEGMENT_END_SEPARATOR="  "
# export POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=" "
# export POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=" |"
# export POWERLEVEL9K_HOME_ICON=" "
# export POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=" "
# export POWERLEVEL9K_LINUX_ARCH_ICON=" "
# export POWERLEVEL9K_NODE_ICON="  "
# export POWERLEVEL9K_OK_ICON="  "
# export POWERLEVEL9K_VCS_GIT_GITLAB_ICON="  "
# export POWERLEVEL9K_VCS_GIT_GITHUB_ICON="  "
# export POWERLEVEL9K_VCS_GIT_ICON="  "
# export POWERLEVEL9K_VCS_BRANCH_ICON="  "
# export POWERLEVEL9K_BATTERY_ICON="  "
# export POWERLEVEL9K_DATE_ICON="  "
# export POWERLEVEL9K_BACKGROUND_JOBS_ICON="  "
# export POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='Ⅴ '

# Change cursor with support for inside/outside tmux
if [[ ! $TERM = "eterm-color" ]]; then
    bindkey -v
    function _set_cursor() {
        if [[ $TMUX = '' ]]; then
          echo -ne $1
        else
          echo -ne "\ePtmux;\e\e$1\e\\"
        fi
    }
    function _set_block_cursor() { _set_cursor '\e[2 q' }
    function _set_beam_cursor() { _set_cursor '\e[6 q' }
    function zle-keymap-select {
      if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
          _set_block_cursor
      else
          _set_beam_cursor
      fi
    }
    zle -N zle-keymap-select
    # ensure beam cursor when starting new terminal
    precmd_functions+=(_set_beam_cursor)
    # ensure insert mode and beam cursor when exiting vim
    zle-line-init() { zle -K viins; _set_beam_cursor }
    # 10ms for key sequences
    KEYTIMEOUT=1
fi

# Generic Functions
# steal children, murder parent
steal() {
    if [[ $# == 0 || (($# > 2)) ]]; then
        echo "steal {directory} [location]"
        return 1
    fi

    mv $1/*(DN) ./$2
    rmdir $1 # only delete directory if it is empty
}

# ls on cd
function cd {
  builtin cd "$@" && ls -aF
}

# FZF
# generate path
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# search on lines of every file in current directory
# return files which match the searched line
fzf-lines() {
    # get every line in directory '$1'
    # regex=${1:-"."} # default to all files
    # paths=${${@:2}:-"."} # default to current directory
    # lines=$(fd "$regex" $paths -t f -x cat {} | fzf +m)
    lines=$(fd $@ -t f -x cat {} | fzf +m)
    # get all lines that match users selection
    rg -s -F -l "$lines" | fzf -1
}

# 'fzf' on all lines in all files found with 'fd'
# populate 'vim' quickfix with results
fzf-vim() {
    # lines=$(fd $@ -t f -x cat {} | fzf -m)
    quickfix=$(rg --vimgrep -F -f <(fd $@ -t f -x cat {} | fzf -m)) # generate quickfix for vim
    # quit if no results
    [[ -z $quickfix ]] && return
    vim -q <(echo -n $quickfix) # open vim, populating quickfix
}

# fzf cd
fzf-cd() {
  fd -t d . ${1:-.} | fzf
}

# fzf cd to file dir
fzf-cf() {
    files=$(fd -t f | fzf)
    if [[ -n $files ]]; then
        cd $(dirname $files)
    fi
}

clean-pdfs() {
size=$(ls "$HOME/reading/downloads" | wc -l)
for f in "$HOME/reading/downloads/"*; do
    if [[ -f "$f" ]]; then
        if [[ ! "$f" =~ \.download ]]; then
            echo "Download in progress."
            return
        fi
        # use awk/sed here instead
        orig=$f
        f=${f:gs/ (z-lib.org)/}
        f=${f:gs/(/ /} # remove parentheses
        f=${f:gs/)/ /} # remove parentheses
        f=${f:gs/, /,}
        f=${f:gs/ \(/\(}
        f=${f:gs/ /-}
    fi
    if [[ $orig != $f ]]; then
        mv "$orig" "$f"
    fi
    mv $f "$HOME/reading"
    # downloads is in this folder so ignore it
    ls -c "$HOME/reading" | head -$(($size + 1)) | tail -$size | xclip
    # Before copying each line to xclip, format as vim would do
done
}

genpwd() {
    tr -dc 'a-zA-Z0-9!' < /dev/random | fold -w 16 | head -1
}

forever() {
    $@
    while inotifywait -r -e modify .; do
        clear
        $@ # run function
    done
}

ssh-tmux() {
    ssh -t $@ -- /bin/sh -c 'tmux has-session && exec tmux attach || exec tmux'
}

compdef _ssh ssh-tmux

# bindkey [-l]  <- to view binded keys and their respective commands
bindkey "^E" list-expand  # for completion
