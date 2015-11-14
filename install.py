#!/usr/bin/python
import os
from datetime import datetime
from os.path import exists
from distutils.spawn import find_executable
from subprocess import call

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
LOG_FILE = open(SCRIPT_DIR + "/error.log", "w")
HOME = os.path.expanduser('~')

def ask(question, default=None):
    yes_answers = {'Y', 'y', 'yes'}
    no_answers = {'N', 'n', 'no'}
    if default is None:
        prompt = "y/n"
    elif default:
        prompt = "Y/n"
    elif not default:
        prompt = "y/N"

    while True:
        user_input = raw_input(question + ' [{}]: '.format(prompt))
        if user_input in yes_answers:
            return True
        if user_input in no_answers:
            return False
        if not user_input and default != None:
            return default
        print("Did not recognize input: {}".format(user_input))

def log_error(message):
    time = datetime.now()
    print(message)
    LOG_FILE.write(str(time) + ": " + message + "\n")

def is_installed(program_name):
    if find_executable(program_name):
        return True
    return False

def install_debian(package_name):
    call(["sudo", "apt-get", "install", package_name])

def link_file(target, source):
    interactive = "-i"
    symbolic = "-s"
    call(["ln", interactive, symbolic, source, target])

def install_zsh():
    log_error("install_zsh not implemented..")

def install_tmux():
    tmux_installed = is_installed("tmux")
    if not tmux_installed:
        install_debian("tmux")
    else:
        log_error("tmux is already installed.")
        if not ask("Would you like to overwrite tmux config with those in" +
                " this script?", False):
            return
    link_file(HOME + "/.tmux.conf",
            SCRIPT_DIR + "/home/darndt/config/tmux/.tmux.conf")

def setup_locale_debian():
    if not ask("Would you like to configure locales for Debian?", True):
        return
    call(["sudo", "dpkg-reconfigure", "locales"])

def initialize_apt():
    print("Updating apt-get...")
    call(["sudo", "apt-get", "update"])

def install_ycm():
    install_debian("vim-youcompleteme")
    link_file(HOME + "~/.vim_runtime/sources_non_forked/vim-youcompleteme",
            "/usr/share/vim-youcompleteme")

def git_clone(git_url, target_directory):
    if exists(target_directory):
        log_error("Error, {} already exists. Will not clone {}".format(
                target_directory, git_url))
        return
    call(["git", "clone", git_url, target_directory])

def install_vim_plugins():
    install_ycm()
    git_clone("https://github.com/godlygeek/csapprox.git",
            "~/.vim_runtime/sources_non_forked/csapprox")
    git_clone("https://github.com/majutsushi/tagbar",
            "~/.vim_runtime/sources_non_forked/tagbar")
    git_clone("https://github.com/xolox/vim-misc",
            "~/.vim_runtime/sources_non_forked/vim-misc")
    git_clone("https://github.com/xolox/vim-easytags.git",
            "~/.vim_runtime/sources_non_forked/vim-easytags")
    call(["sudo", "apt-get", "install", "exuberant-ctags"])
    link_file("~/.vim_runtime/sources_forked/theme-foursee",
            SCRIPT_DIR + "/vim/sources_forked/theme-foursee")
    link_file("~/.vim_runtime/my_configs.vim",
            SCRIPT_DIR + "/vim/my_configs.vim")
    link_file("~/.ctags", SCRIPT_DIR + "/vim/.ctags")

def install_vim():
    print("Installing vim...")
    git_clone("https://github.com/amix/vimrc.git", HOME + "/.vim_runtime")
    install_debian("vim-nox")
    if ask("Would you like to switch default editors?", False):
        call(["sudo", "update-alternatives", "--config", "editor"])
    install_vim_plugins()
    call(["git", "config", "--global core.editor", find_executable("vim")])
    link_file(HOME + "/.vimrc", SCRIPT_DIR + "/vim/.vimrc")

def install_thefuck():
    install_debian("python-dev python-pip")
    call(["sudo", "pip", "install", "thefuck", "--upgrade"])

def install_all():
    initialize_apt()
    setup_locale_debian()
    install_vim()
    install_thefuck()
    install_tmux()
    install_zsh()


if __name__ == "__main__":
    if not ask("This script only works on Debian / Ubuntu. Would you like to " +
            "continue?", True):
        exit()
    if not ask("Are the config files located at <{}>?".format(SCRIPT_DIR),
            True):
        print("Sorry, there was an error detecting the location of the " +
                "install files.")
        print("Please log a defect.")
        exit()
    install_all()
