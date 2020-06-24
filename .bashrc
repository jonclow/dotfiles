#!/bin/bash
# This file runs every time you open a new terminal window.

# wherewolf specific
source ~/code/helperscripts/bash/core
# put helper scripts on path
export WW_CODE_DIR=~/code
export PATH=$PATH:~/code/helperscripts

# Limit number of lines and entries in the history.
export HISTFILESIZE=50000
export HISTSIZE=50000

# History across sessions
PROMPT_COMMAND="history -n; history -a"

# Add a timestamp to each command.
export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S:   "

# Duplicate lines and lines starting with a space are not put into the history.
export HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it.
shopt -s histappend
shopt -s histverify
set -b

# Ensure $LINES and $COLUMNS always get updated.
shopt -s checkwinsize

# Enable bash completion.
[ -f /etc/bash_completion ] && . /etc/bash_completion

# Improve output of less for binary files.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Load aliases if they exist.
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# Determine git branch.
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Set a non-distracting prompt.
PS1='\[[01;32m\]\u@\h\[[00m\]:\[[01;34m\]\w\[[00m\] \[[01;33m\]$(parse_git_branch)\[[00m\]\$ '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Enable a better reverse search experience.
#   Requires: https://github.com/junegunn/fzf (to use fzf in general)
#   Requires: https://github.com/BurntSushi/ripgrep (for using rg below)
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"

# WSL 2 specific settings.
# set DISPLAY variable to the IP automatically assigned to WSL2
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
# Cypress uses dbus to communicate, auto-start it
sudo /etc/init.d/dbus start &> /dev/null

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Bind up/down arrows history search.
case "$TERM" in *xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix|screen|screen-256color)
    bind '"\e[A": history-search-backward' >/dev/null 2>/dev/null
    bind '"\e[B": history-search-forward' >/dev/null 2>/dev/null
    color_prompt=yes
    ;;
*)
    ;;
esac
# Set tmux/screen window titles
case "$TERM" in
    screen)
        export PROMPT_COMMAND='echo -ne "\033]2;${USER}@${HOSTNAME}: ${PWD}\007\033k${USER}@${HOSTNAME}\033\\";  prompt_command'
        ;;
*)
    export PROMPT_COMMAND='prompt_command;'
    ;;
esac

function prompt_command {
    # Run this function every time a prompt is displayed.
    # Make history happen, regardless of windows/panes/tabs/etc
    history -n
    history -a
    # Set term title to user@hostname/pwd
    echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"
    #Give a new line - the -e flag is for echo to enable interpretaion of backslash escapes
    #echo -e "\n"
    echo ''
    ### Check if restart is required
    # Debian/Ubuntu
    if [ -f /var/run/reboot-required ]; then
        echo -e '\e[1;7m *** RESTART REQUIRED *** \e[0m due to:'
        cat /var/run/reboot-required.pkgs
    fi
}