#!/usr/bin/python3

import argparse
import os
import shlex
import subprocess
from datetime import datetime
from os.path import exists
from distutils.spawn import find_executable

HOME = os.path.expanduser('~')
try:
    SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
except:
    SCRIPT_DIR = HOME + "/config/"
LOG_FILE = open(SCRIPT_DIR + "/error.log", "w")

interactive = True

def get_arguments():
    parser = argparse.ArgumentParser(description='Setup a custom environment.')
    parser.add_argument('--role', help='Only install this role')
    parser.add_argument('--tags', help='Only run these tags')
    parser.add_argument('--non-interactive', help='Don\'t ask questions, just accept the default.', action="store_true")
    parser.add_argument('--diff', help='Show changes', action="store_true")
    return parser.parse_args()


def ask(question, default=None):
    if not interactive:
        return default
    yes_answers = {'Y', 'y', 'yes'}
    no_answers = {'N', 'n', 'no'}
    if default is None:
        prompt = "y/n"
    elif default:
        prompt = "Y/n"
    elif not default:
        prompt = "y/N"

    while True:
        user_input = input(question + ' [{}]: '.format(prompt))
        if user_input in yes_answers:
            return True
        if user_input in no_answers:
            return False
        if not user_input and default is not None:
            return default
        print("Did not recognize input: {}".format(user_input))


def log_error(message):
    time = datetime.now()
    print(message)
    LOG_FILE.write(str(time) + ": " + message + "\n")


def shell_call(command_str, cwd=HOME, raise_exception=True):
    cmd = shlex.split(command_str)
    ret_code = subprocess.call(cmd, cwd=cwd)
    if ret_code != 0 and raise_exception:
        raise Exception('Error running command "{}": {}'.format(command_str, ret_code))
    return ret_code


def install_debian(package_name):
    if interactive:
        shell_call('sudo apt-get install {}'.format(package_name))
    else:
        shell_call('sudo apt-get install -y {}'.format(package_name))


def install_pip(package_name):
    shell_call('pip install --user {}'.format(package_name))


def link_file(target, source):
    interactive = '-i'
    symbolic = '-s'
    options = ' '.join([interactive, symbolic])
    shell_call('ln {options} {} {}'.format(source, target, options=options))


def initialize_apt():
    print("Updating apt-get...")
    shell_call('sudo apt-get update')


def install_ycm():
    install_debian("vim-youcompleteme")
    # FIXME: Broken. See https://github.com/DanielArndt/config/issues/25
    #link_file(HOME + "/.vim_runtime/sources_non_forked/vim-youcompleteme",
    #          "/usr/share/vim-youcompleteme")


def git_clone(git_url, target_directory):
    if exists(target_directory):
        log_error("Error, {} already exists. Will not clone {}".format(
                target_directory, git_url))
        return
    shell_call('git clone {url} {target_directory}'.format(
        url=git_url,
        target_directory=target_directory))


def install_vim_plugins():
    install_ycm()
    git_clone("https://github.com/godlygeek/csapprox.git",
              HOME + "/.vim_runtime/sources_non_forked/csapprox")
    git_clone("https://github.com/majutsushi/tagbar",
              HOME + "/.vim_runtime/sources_non_forked/tagbar")
    git_clone("https://github.com/xolox/vim-misc",
              HOME + "/.vim_runtime/sources_non_forked/vim-misc")
    git_clone("https://github.com/xolox/vim-easytags.git",
              HOME + "/.vim_runtime/sources_non_forked/vim-easytags")
    git_clone("https://github.com/christoomey/vim-tmux-navigator",
              HOME + "/.vim_runtime/sources_non_forked/vim-tmux-navigator")
    install_debian('exuberant-ctags')
    link_file(HOME + "/.ctags", SCRIPT_DIR + "/vim/.ctags")


def install_ansible():
    is_ansible_installed = find_executable('ansible-playbook')
    if is_ansible_installed:
        print('ansible playbook already installed')
        return

    initialize_apt()
    install_debian('python3-pip')
    shell_call('pip3 install  --user -U pip setuptools cryptography')
    shell_call('pip3 install --user ansible')


def install_ansible_toolbox():
    is_ansible_toolbox_installed = find_executable('ansible-role')
    if is_ansible_toolbox_installed:
        print('ansible toolbox already installed')
        return

    shell_call('pip3 install --user ansible-toolbox')


def get_opt_str(args):
    opts = ''
    if args.tags:
        opts += ' --tags ' + args.tags
    if args.diff:
        opts += ' --diff'
    return opts


def install_role(args):
    print('Installing role: {}'.format(args.role))
    additional_opts = get_opt_str(args)
    cmd_str = 'ansible-role -i "localhost," -c local {role} --ask-become-pass -e "ansible_python_interpreter=/usr/bin/python3" {additional_opts}'.format(role=args.role, additional_opts=additional_opts)
    shell_call(
        cmd_str,
        cwd=os.path.join(SCRIPT_DIR, 'ansible'),
        raise_exception=False,
    )


def install_all_roles(args):
    additional_opts = get_opt_str(args)
    shell_call(
        'ansible-playbook -i "localhost," -c local master.yml --ask-become-pass -e "ansible_python_interpreter=/usr/bin/python3" {additional_opts}'.format(additional_opts=additional_opts),
        cwd=os.path.join(SCRIPT_DIR, 'ansible'),
        raise_exception=False,
    )



def install_all(args):
    install_ansible()
    if args.role:
        install_ansible_toolbox()
        install_role(args)
        return

    install_all_roles(args)


if __name__ == "__main__":
    args = get_arguments()
    if args.non_interactive:
        interactive = False
    if not ask("This script only works on Debian / Ubuntu. Would you like to continue?",
               default=True):
        exit(1)
    if not ask("Are the config files located at <{}>?".format(SCRIPT_DIR),
               default=True):
        print("Sorry, there was an error detecting the location of the install files.")
        print("Please log a defect.")
        exit(1)

    install_all(args)
