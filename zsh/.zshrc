# Dan stuff

# Without this, tmux will eat the colours!
export TERM=screen-256color

# Prevent zsh from renaming my terminals
export DISABLE_AUTO_TITLE=true

detachAndExit() {
    if [[ -z $TMUX ]]; then
        builtin exit
    else
        tmux detach
    fi
}


sgrep() {
    grep -rnwI --color=auto --exclude-dir={.bzr,.cvs,.git,.hg,.svn} "$1" -e "$2" 2>/dev/null
}

if hash tmux 2>/dev/null; then
    # Tmux is installed, so lets override some things.
    alias logout=detachAndExit
    # Alway re-attach to the previous session
    if [[ -z "$TMUX" ]] ;then
        ID="`tmux ls | cut -d: -f1`" # get the id of a deattached session
        #ID="`tmux ls | grep -vm1 attached | cut -d: -f1`" # get the id of a deattached session
        if [[ -z "$ID" ]] ;then # if not available create a new one
            tmux new-session
        else
            tmux attach-session -t "$ID" # if available attach to it
        fi
        # When we finally leave the session, just exit.
        builtin exit
    fi
fi

export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export HOSTNAME=$(hostname)

# End Dan stuff

source ~/config/zsh/antigen/antigen.zsh
source ~/config/zsh/.antigenrc

# Keep 10000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Use modern completion system
#autoload -Uz compinit
#compinit

# zstyle ':completion:*' auto-description 'specify: %d'
# zstyle ':completion:*' completer _expand _complete _correct _approximate
# zstyle ':completion:*' format 'Completing %d'
# zstyle ':completion:*' group-name ''
# zstyle ':completion:*' menu select=2
# eval "$(dircolors -b)"
# zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# zstyle ':completion:*' list-colors ''
# zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
# zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
# zstyle ':completion:*' menu select=long
# zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
# zstyle ':completion:*' use-compctl false
# zstyle ':completion:*' verbose true

# zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
# zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Use Vi key bindings
bindkey -v

# Reduce the timeout on escape sequences
export KEYTIMEOUT=1

[ -z $HOST ] && export HOST=`hostname`

# Source all configs
for file in $(find ~/config/zsh/.zsh.d/ -type f | sort)
do
    source $file
done
# Not sure why this is needed... it removes 'gnats/' from being in autocompletion
# http://stackoverflow.com/questions/27088092/zsh-prezto-cd-tab-completion-issue
setopt nocdablevars

eval $(thefuck --alias)

export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=WORKON_HOME

export PIP_REQUIRE_VIRTUALENV=true

export SYSTEM_PIP=`which pip`
function syspip {
    PIP_REQUIRE_VIRTUALENV="" sudo -H $SYSTEM_PIP "$@"
}
