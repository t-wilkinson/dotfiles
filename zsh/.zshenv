#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

export ZSH_AUTOSUGGEST_STRATEGY=(completion match_prev_cmd)

# Paths
# NPM
if [[ -z $IN_NIX_SHELL ]];then
    npm config set prefix ~/.npm
fi
path+=$HOME/.npm/bin

# Stack
path+=$HOME/.local/bin

# Scripts
scripts=$HOME/dev/scripts
path+=($scripts $scripts/sites)

path+=($HOME/.gem/ruby/2.7.0/bin)
source ~/.aliases

if [ -e /home/trey/.nix-profile/etc/profile.d/nix.sh ]; then . /home/trey/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
export ANDROID_SDK=/home/trey/Android/Sdk
