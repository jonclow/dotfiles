
#Editor Options
export EDITOR="vim"
export GREP_COLOR="1;33"
export VISUAL=$EDITOR

# Set locale
export LC_ALL=en_NZ.UTF-8
export LANG=en_NZ.UTF-8
export LC_MESSAGES="C"

# wherewolf specific
source ~/Code/helperscripts/bash/core
# put helper scripts on path
export WW_CODE_DIR=~/Code
export PATH=$PATH:~/Code/helperscripts

# Bash options, some of these are already set by default, but to be safe I've defined them here again.
shopt -s cdspell                    # Try to correct spelling errors in the cd command.
# shopt -s checkjobs                # Warn if there are stopped jobs when exiting - May not work on all versions of Bash.
shopt -s checkwinsize               # Check window size after each command and update as nescessary.
shopt -s cmdhist                    # Try to save all multi-line commands to one history entry.
# shopt -s dirspell                 # Try to correct spelling errors for glob matching - May not work on all versions.
shopt -s dotglob                    # include files beginning with a dot in pathname expansion (pressing TAB).
shopt -s expand_aliases             # Self explanatory.
shopt -s extglob                    # Enable extended pattern matching.
shopt -s extquote                   # Command line quoting stuff.
shopt -s force_fignore              # Force ignore for files if FIGNORE is set.
shopt -s interactive_comments       # Allowing commenting, in an interactive shell.
shopt -s login_shell                # Bash is the login shell, obviously.
shopt -s nocaseglob                 # Case insensitive pathname expansion (TAB) some may want to turn this off.
shopt -s progcomp                   # Programmable completion stuff.
shopt -s promptvars                 # Expansion stuff for prompt strings.
shopt -s sourcepath                 # The source command will use the PATH variable.

# if [ "$HOSTNAME" = thinkpad ]; then

  # alias logstalgiaWherewolf='ssh wherewolf-WORKER0001 "tail -f /var/log/nginx/wherewolf.log" | logstalgia --sync --full-hostnames --update-rate 1 -g "API,URI=.*,100"'

  # alias logstalgiaWherewolf='ssh wherewolf-WORKER0001 "tail -f /var/log/nginx/wherewolf.log" | grep -v "uptimeCheck" | logstalgia --sync --full-hostnames --update-rate 1 -g "API,URI=.*,100"'

# fi

##### History management section
HISTFILESIZE=100000000
HISTSIZE=100000000
shopt -s histappend
shopt -s histverify
set -b

# Completion
complete -cf sudo
complete -C aws_completer aws
shopt -s no_empty_cmd_completion    # Self explanatory.
shopt -s hostcomplete               # Complete hostnames (TAB).
set completion-ignore-case on       # turn off case sensitivity

complete -W "$(echo `cat ~/.bash_history | egrep '^ssh ' | sort | uniq | sed 's/^ssh //'`;)" ssh    # SSH Hostname autocomplete
complete -W "$(echo `cat ~/.bash_history | egrep '^mosh ' | sort | uniq | sed 's/^mosh //'`;)" mosh

# History across sessions
PROMPT_COMMAND="history -n; history -a"

##### Aliases and commands
# modified commands

alias ..='cd ..'
alias df='df -h'
alias diff='colordiff'              # requires colordiff package
alias du='du -c -h'
alias grep='grep --color=auto'
alias mkdir='mkdir -p -v'
alias ping='ping -c 5'
alias visudo='sudo -E visudo'
alias vi='vim'

# Stop doing dumb things
alias more='less'
alias nano='vim'

# new commands
# count inodes: find . -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort –n
alias aptiupdate='sudo apt update && sudo apt upgrade'
alias du1='du --max-depth=1'
alias hist='history | grep $1'      # requires an argument
alias fact="elinks -dump randomfunfacts.com | sed -n '/^│ /p' | tr -d \│"
alias srcbashrc='source ~/.bashrc'
alias srcbashprofile='source ~/.bash_profile'
alias openports='netstat --all --numeric --programs --inet'
alias whoshitting="sudo netstat -anp | grep 'tcp\|upd' | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n"
alias apacheloguseragents="tail -n 10 -F /var/log/apache2/access.log | awk -F\" '{print $6}'"
# alias aw='tmux attach -t wulf'

## get current git branch
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Turn on colours.
#case "$TERM" in
#    xterm-color)
#    color_prompt=yes;;
#esac

# make a function called '=' which is a shortcut to 'bc', a calculator of sorts
#  usage: 
#  $ = 180/50
#  $ = 100-90
=() {
    calc="${@//p/+}"
    calc="${calc//x/*}"
    bc -l <<<"scale=10;$calc"
}

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
    # Arch
    NEXTLINE=0
    FIND=""
    for I in `file /boot/vmlinuz*`; do
      if [ ${NEXTLINE} -eq 1 ]; then
        FIND="${I}"
        NEXTLINE=0
       else
        if [ "${I}" = "version" ]; then NEXTLINE=1; fi
      fi
    done
    if [ ! "${FIND}" = "" ]; then
      CURRENT_KERNEL=`uname -r`
      if [ ! "${CURRENT_KERNEL}" = "${FIND}" ]; then
        echo -e '\e[1;7m *** RESTART REQUIRED *** \e[0m'
      fi
    fi
}
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
# Prompt, Looks like:
# ┌─[username@host]-[time date]-[directory]
# └─[$]->
PS1='\[\e[0;36m\]┌─[\[\e[0;32m\]\u\[\e[0;34m\]@\[\e[0;31m\]\h\[\e[0m\e[0;36m\]]-[\[\e[0m\]`date +%Y-%m-%d\ %R` - `date +%s`\[\e[0;36m\]]-[\[\e[33;1m\]\w\[\e[0;36m\]]\[\e[0;32m\]`parse_git_branch`\n\[\e[0;36m\]└─[\[\e[35m\]\$\[\e[0;36m\]]->\[\e[0m\] '
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*