#!/usr/bin/python
import os
from os.path import isfile
from distutils.spawn import find_executable
from subprocess import call

SCRIPT_DIR = os.getcwd()
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
    print(message)
    LOG_FILE.write(message + "\n")

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
    link_file(HOME + ".tmux.conf",
            SCRIPT_DIR + "/home/darndt/config/tmux/.tmux.conf")
