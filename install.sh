#!/bin/bash

ask() {
    while true; do
 
        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi
 
        # Ask the question
        read -p "$1 [$prompt] " REPLY
 
        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi
 
        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
 
    done
}

# Remind user to set up a different editor
if ask "Would you like to switch default editors?"; then
    sudo update-alternatives --config editor
fi

if ask "Would you like to install zsh?"; then
    exec ~/config/installZsh.sh
fi
