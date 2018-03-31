#!/usr/bin/python

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


def get_arguments():
    parser = argparse.ArgumentParser(description='Setup a custom environment.')
    parser.add_argument('--role', help='Only install this role')
    return parser.parse_args()


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
        if not user_input and default is not None:
            return default
        print("Did not recognize input: {}".format(user_input))


def log_error(message):
    time = datetime.now()
    print(message)
    LOG_FILE.write(str(time) + ": " + message + "\n")


def shell_call(command_str, cwd=HOME, raise_exception=False):
    cmd = shlex.split(command_str)
    ret_code = subprocess.call(cmd, cwd=cwd)
    if ret_code != 0:
        raise Exception('Error running command "{}": {}'.format(command_str, ret_code))
    return ret_code


def install_debian(package_name):
    shell_call('sudo apt-get install {}'.format(package_name))


def install_pip(package_name):
    shell_call('sudo pip install {}'.format(package_name))


def link_file(target, source):
    interactive = '-i'
    symbolic = '-s'
    options = ' '.join([interactive, symbolic])
    shell_call('ln {options} {} {}'.format(source, target, options=options))


def install_zsh():
    install_debian('zsh')
    git_clone("https://github.com/zsh-users/antigen.git",
              SCRIPT_DIR + "/zsh/antigen")
    link_file(HOME + "/.zshrc", SCRIPT_DIR + "/zsh/.zshrc")
    shell_call('chsh -s /bin/zsh')
    if os.environ['SHELL'] != '/bin/zsh':
        shell_call('zsh')


def install_git():
    shell_call('mkdir -p {home}/.git_template/hooks'.format(home=HOME))
    link_file(HOME + "/.git_template/hooks/ctags",
              SCRIPT_DIR + "/git/.git_template/hooks/ctags")
    link_file(HOME + "/.git_template/hooks/post-checkout",
              SCRIPT_DIR + "/git/.git_template/hooks/post-checkout")
    link_file(HOME + "/.git_template/hooks/post-commit",
              SCRIPT_DIR + "/git/.git_template/hooks/post-commit")
    link_file(HOME + "/.git_template/hooks/post-merge",
              SCRIPT_DIR + "/git/.git_template/hooks/post-merge")
    link_file(HOME + "/.git_template/hooks/post-rewrite",
              SCRIPT_DIR + "/git/.git_template/hooks/post-rewrite")
    link_file(HOME + "/.git_template/hooks/pre-push",
              SCRIPT_DIR + "/git/.git_template/hooks/pre-push")
    shell_call('git config --global init.templatedir {home}/.git_template'
               .format(home=HOME))


def install_tmux():
    tmux_location = find_executable("tmux")
    if not tmux_location:
        install_debian("tmux")
    else:
        log_error("tmux is already installed.")
        if not ask("Would you like to overwrite tmux config with those in this script?",
                   default=False):
            return
    link_file(HOME + "/.tmux.conf", SCRIPT_DIR + "/tmux/.tmux.conf")


def setup_locale_debian():
    if not ask("Would you like to configure locales for Debian?",
               default=False):
        return
    shell_call('sudo dpkg-reconfigure locales')


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


def install_vim():
    print("Installing vim...")
    git_clone("https://github.com/DanielArndt/vim-config.git",
              HOME + "/.vim_runtime")
    # TODO link .vimrc
    shell_call('git submodule update --init --recursive',
               cwd=HOME + '/.vim_runtime/')
    install_debian("vim-nox")
    if ask("Would you like to switch default editors?", default=False):
        shell_call('sudo update-alternatives --config editor')
    install_vim_plugins()
    vim_location = find_executable('vim')
    shell_call('git config --global core.editor {}'.format(vim_location))
    link_file(HOME + "/.vimrc", SCRIPT_DIR + "/vim/.vimrc")


def install_thefuck():
    install_debian("python-dev")
    install_debian("python-pip")
    shell_call('sudo pip install thefuck --upgrade')


def install_ansible():
    is_ansible_installed = find_executable('ansible-playbook')
    if is_ansible_installed:
        print('ansible playbook already installed')
	return

    initialize_apt()
    install_debian('python-pip')
    shell_call('sudo -H pip install -U pip setuptools')
    shell_call('sudo -H pip install ansible')


def install_ansible_toolbox():
    is_ansible_toolbox_installed = find_executable('ansible-role')
    if is_ansible_toolbox_installed:
        print('ansible toolbox already installed')
        return

    shell_call('sudo -H pip install ansible-toolbox')


def install_role(role):
    shell_call(
        'ansible-role -i "localhost," -c local {role} --ask-become-pass'.format(role=role),
        cwd=os.path.join(SCRIPT_DIR, 'ansible')
    )


def install_all_roles():
	shell_call(
        'ansible-playbook -i "localhost," -c local master.yml --ask-become-pass',
        cwd=os.path.join(SCRIPT_DIR, 'ansible')
    )



def install_all():
    args = get_arguments()
    install_ansible()
    if args.role:
        install_ansible_toolbox()
        install_role(args.role)
        return

    install_all_roles()
    #install_git()
    #setup_locale_debian()
    #install_vim()
    #install_thefuck()
    #install_tmux()
    #install_zsh()


if __name__ == "__main__":
    if not ask("This script only works on Debian / Ubuntu. Would you like to continue?",
               default=True):
        exit(1)
    if not ask("Are the config files located at <{}>?".format(SCRIPT_DIR),
               default=True):
        print("Sorry, there was an error detecting the location of the install files.")
        print("Please log a defect.")
        exit(1)

    install_all()
