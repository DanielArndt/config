#!/bin/bash
SCRIPT_DIR=$(readlink -f $(dirname $0))

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
        exec $SCRIPT_DIR/zsh/install.sh
    fi
}

installTmux(){
    sudo apt-get install tmux
    ln -i -s $SCRIPT_DIR/tmux/.tmux.conf $HOME/.tmux.conf
}


setupLocaleDebian(){
    if ask "Would you like to configure locales for Debian?"; then
        echo "Setting up locales for Debian"
        sudo dpkg-reconfigure locales
    fi
}

setupLinux(){
    echo "Updating apt-get..."
    sudo apt-get update # Make sure everything is up to date.
    setupLocaleDebian
}

installYcm() {
    sudo apt-get install vim-youcompleteme
    ln -s /usr/share/vim-youcompleteme \
        ~/.vim_runtime/sources_non_forked/vim-youcompleteme
}

gitCloneIfNotExists() {
    gitUrl=$1
    directory=$2
    if [ ! -d "$directory" ]; then
        git clone $gitUrl $directory
    fi
}


installVimPlugins() {
    installYcm
    cd ~/.vim_runtime/sources_non_forked
    gitCloneIfNotExists https://github.com/godlygeek/csapprox.git ~/.vim_runtime/sources_non_forked/csapprox
    gitCloneIfNotExists https://github.com/majutsushi/tagbar ~/.vim_runtime/sources_non_forked/tagbar
    gitCloneIfNotExists https://github.com/xolox/vim-misc ~/.vim_runtime/sources_non_forked/vim-misc
    gitCloneIfNotExists https://github.com/xolox/vim-easytags.git ~/.vim_runtime/sources_non_forked/vim-easytags
    sudo apt-get install exuberant-ctags
    ln -s $SCRIPT_DIR/vim/sources_forked/theme-foursee ~/.vim_runtime/sources_forked/theme-foursee
    ln -s $SCRIPT_DIR/vim/my_configs.vim ~/.vim_runtime/my_configs.vim
    ln -s $SCRIPT_DIR/vim/.ctags ~/.ctags
}

installVim() {
    echo "Installing vim"
    git clone https://github.com/amix/vimrc.git ~/.vim_runtime
    case $operatingSystem in
        'LINUX' )
            sudo apt-get install vim-nox
            # Remind user to set up a different editor
            if ask "Would you like to switch default editors?"; then
                sudo update-alternatives --config editor
            fi
            installVimPlugins
            ;;
        'MAC')
            brew install vim
            ;;
    esac
    # Setting default git editor to vim.
    git config --global core.editor $(which vim)
    ln -i -s $SCRIPT_DIR/vim/.vimrc $HOME/.vimrc
}

installTheFuck() {
    sudo apt-get install python-pip
    sudo pip install thefuck --upgrade
}

installAllLinux() {
    setupLinux
    installVim
    installTheFuck
    installTmux
    installZsh
}

installAllMac() {
    if hash brew 2>/dev/null; then
        echo "Homebrew already installed. Skipping installation."
    else
        echo "Installing homebrew for Mac."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    echo "Updating homebrew"
    brew update

    brew install git
    installVim
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

if ! ask "Are the config files located at <$SCRIPT_DIR>?" "Y"; then
    echo "Sorry, there was an error detecting the location of the install files."
    echo "Please log a defect."
    exit 1
fi

case $operatingSystem in
    'LINUX' )
        installAllLinux;;
    'MAC' )
        installAllMac;;
esac

