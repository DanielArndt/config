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

installTmux(){
    sudo apt-get install tmux
    ln -i -s $installDir/tmux/.tmux.conf $HOME/.tmux.conf
}


setupLocaleDebian(){
    if ask "Would you like to configure locales for Debian?"; then
        echo "Setting up locales for Debian"
        sudo dpkg-reconfigure locales
    fi
}

setupLinux(){
    setupLocaleDebian
}

installYcm() {
    cd ~/.vim_runtime/sources_non_forked
    git clone https://github.com/Valloric/YouCompleteMe.git
    cd YouCompleteMe
    git submodule update --init --recursive
    sudo apt-get install llvm-dev build-essential python-dev cmake libclang-dev 
    cd ~
    mkdir ycm_build
    cd ycm_build
    cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON ~/ycm_build ~/.vim_runtime/sources_non_forked/YouCompleteMe/third_party/ycmd/cpp
    make ycm_support_libs
}

installVimPlugins() {
    installYcm
    git clone https://github.com/godlygeek/csapprox.git ~/.vim_runtime/sources_non_forked/csapprox
    git clone https://github.com/majutsushi/tagbar ~/.vim_runtime/sources_non_forked/tagbar
    git clone https://github.com/xolox/vim-misc ~/.vim_runtime/sources_non_forked/vim-misc
    git clone https://github.com/xolox/vim-easytags.git ~/.vim_runtime/sources_non_forked/vim-easytags
    sudo apt-get install exuberant-ctags
    ln -s ~/config/vim/sources_forked/theme-foursee ~/.vim_runtime/sources_forked/theme-foursee
    ln -s ~/config/vim/my_configs.vim ~/.vim_runtime/my_configs.vim
    ln -s ~/config/vim/.ctags ~/.ctags
}

installVim() {
    echo "Installing vim"
    case $operatingSystem in
        'LINUX' )
            sudo apt-get install vim-nox
            # Remind user to set up a different editor
            if ask "Would you like to switch default editors?"; then
                sudo update-alternatives --config editor
            fi
            git clone https://github.com/amix/vimrc.git ~/.vim_runtime
            installVimPlugins
            ;;
        'MAC')
            brew install vim
            ;;
    esac
    # Setting default git editor to vim.
    git config --global core.editor $(which vim)
    #echo "Installing vundle -- plugin manager for vim"
    #git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
    git clone https://github.com/amix/vimrc.git ~/.vim_runtime
    ln -i -s $installDir/vim/.vimrc $HOME/.vimrc
}

installAllLinux() {
    setupLinux
    installVim
    installZsh
    installTmux
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

if ! ask "Are the config files located at <$installDir>?" "Y"; then
    echo "Currenty, the files must be located in your home directory."
fi

case $operatingSystem in
    'LINUX' )
        installAllLinux;;
    'MAC' )
        installAllMac;;
esac

