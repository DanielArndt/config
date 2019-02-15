# ZSH aliases

if [[ `uname` != 'Darwin' ]]
then
    alias ls='ls --color'
fi
alias o='open "$@"'

# Use apt-fast if it exists
if hash apt-fast 2>/dev/null; then
    alias apt-get="apt-fast"
fi

# Fix ag colours
alias ag='ag --color-line="0;33" --color-path="0;32"'

# Alias gv to gvim if it exists
if hash gvim 2>/dev/null; then
    function gv { ( gvim -f "$@" & ) &>/dev/null ; }
    compdef gv=gvim
fi

# Only set git aliases if git exists
if hash git 2>/dev/null; then
    # Git aliases
    # Use hub if it exists
    if hash hub 2>/dev/null; then
        alias g="hub"
        alias git="hub"
        compdef hub=git
    else
        alias g="git"
    fi

    alias gb="git branch"
    alias gd="git diff"
    alias gdc="git diff --cached"
    alias gg="git gui&"
    alias gl="git l"
    alias glp="git lp"
    alias gst="git status -sb"
    alias gc!="git commit --amend --reset-author"

    function ghra {
        python3 ~/config/zsh/github.py remote add $@
    }

    function gmod {
        local _path=$(git rev-parse --show-toplevel || pwd)
        local _files=

        # changed files
        #echo "1: $1"
        [[ -z "$1" ]] && _files="$(cd $_path ; git status --porcelain | sed 's/^ *[^ ]* *//' | sort -u)"
        #echo "f1: $_files"

        # files changed in HEAD
        [[ -z $_files ]] && _files="$(cd $_path; git diff-tree --no-commit-id --name-only -r ${1:-HEAD})"
        #echo "f2: $_files"
        _files=$(echo "$_files" | sed "s!^!$_path/!" | grep -v '/images/' | while read line ; do file "$line" | grep -q '\btext\b' && echo $line ; done)
        #echo "f3: $_files"

        gv $(echo "$_files" | xargs echo)
    }
fi

alias ll='ls -alh --color=auto'
alias lr='ls -lh --color=auto'
# Replace rm with rm -i to avoid accidental removals. Add del for
# "deleting" by moving to a temporary directry.
alias del='mkdir -p /tmp/$USER && mv --verbose -f --backup=numbered --target-directory /tmp/$USER'
alias rm='rm -i'
backup() {
    backupLocation="$1.bak"
    i=''
    while [ -e $backupLacation$i ]
    do
        ((i++))
    done
    echo "Backing up to $backupLocation$i"
    cp -R --backup=numbered $1 $backupLocation$i
}
alias bak='backup'
alias syncssh='rsync --partial --progress --rsh=ssh'

if hash docker 2>/dev/null; then
    alias d='docker'
    alias di='docker images'
fi

if hash docker-compose 2>/dev/null; then
    alias dcom='docker-compose'
fi

if hash tmux 2>/dev/null; then
    function ta() {
        tmux start-server\; has-session -t $1 2>/dev/null
        if [ "$?" -eq 1 ]; then
            # Does not exist, create it
            TMUX= tmux new-session -d -s $1 -n $1
        fi
        if [ -z "$TMUX" ]; then
            tmux -u attach -t $1
        else
            tmux -u switch-client -t $1
        fi
    }
fi
