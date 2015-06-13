#!/bin/bash
installDir="$HOME/config"

# Define the 'ask' function. This makes it easy to ask yes/no questions.
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

detectOperatingSystem() {
    local os=`uname`
    case $os in
        'Darwin')
            echo "Operating system: Mac"
            operatingSystem="MAC";;
        'Linux')
            echo "Operating system: Linux"
            operatingSystem="LINUX";;
        *)
            echo "Operating System: Unknown"
            operatingSystem="OTHER";;
    esac
}

installZsh() {
    if ask "Would you like to install zsh?"; then
        exec $installDir/zsh/install.sh
    fi
}

installAllLinux() {
    installVim
    installZsh
}

installVim() {
    echo "Installing vim"
    case $operatingSystem in
        'LINUX' )
            sudo apt-get install vim
            # Remind user to set up a different editor
            if ask "Would you like to switch default editors?"; then
                sudo update-alternatives --config editor
            fi
            ;;
        'MAC')
            brew install vim
            ;;
    esac
    
    ln -s $installDir/vim/.vimrc $HOME/.vimrc
}

installAllMac() {
    if hash brew 2>/dev/null; then
        echo "Homebrew already installed"
    else
        echo "Installing homebrew for Mac."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    brew update
    
    installVim
    brew install git
    brew install wget

    if hash zsh 2>/dev/null; then
        echo "zsh already installed... skipping."
    else
        echo "Installing zsh"
        installZsh
    fi
}

#### Begin main ####
detectOperatingSystem

if [[ $operatingSystem == "OTHER" ]]; then
    echo "Cannot detect OS. Giving up."
    exit 1
fi

if ! ask "Is the above information correct?" "Y"; then
    echo "Then lets give up. This sounds difficult and I don't really know what I'm doing."
    exit 1
fi

if ! ask "Are the config files located at <$installDir>?" "Y"; then
    echo "Currenty, the files must be located in your home directory."
fi

case $operatingSystem in
    'LINUX' )
        installAllLinux;;
    'MAC' )
        installAllMac;;
esac

