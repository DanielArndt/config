#!/usr/bin/python3

import argparse
import os
import shlex
import subprocess
import logging
from distutils.spawn import find_executable

HOME = os.path.expanduser('~')
try:
    SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
except Exception:
    SCRIPT_DIR = HOME + "/config/"

interactive = True


def get_arguments():
    parser = argparse.ArgumentParser(description='Setup a custom environment.')
    parser.add_argument('--role', help='Only install this role')
    parser.add_argument('--tags', help='Only run these tags')
    parser.add_argument('--skip-tags', help='Run without these tags')
    parser.add_argument('--non-interactive', help="Don't ask questions, just accept the default.", action="store_true")
    parser.add_argument('--diff', help='Show changes', action="store_true")
    parser.add_argument('--install', help="Preform the install.", action="store_true")
    parser.add_argument('--verbose', help="Set log level to debug", action="store_true")
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


def shell_call(command_str, cwd=HOME, raise_exception=True, **kwargs):
    logging.debug(f"shell command: {command_str}")
    cmd = shlex.split(command_str)
    ret_code = subprocess.call(cmd, cwd=cwd, **kwargs)
    if ret_code != 0 and raise_exception:
        raise Exception('Error running command "{}": {}'.format(command_str, ret_code))
    return ret_code


def install_debian(package_name):
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


def install_ansible():
    is_ansible_installed = find_executable('ansible-playbook')
    if is_ansible_installed:
        print('ansible playbook already installed')
        return

    initialize_apt()
    install_debian('python3-pip')
    shell_call('python3 -m pip install --user -U pip setuptools cryptography')
    # Pip is updated now, which may break the default debian script. Pass the
    # right path so that it uses the right pip init script.
    env = os.environ
    env['PATH'] = '{home}/.local/bin:'.format(home=HOME) + env['PATH']
    shell_call('pip3 install --user ansible', env=env)


def install_ansible_toolbox():
    is_ansible_toolbox_installed = find_executable('ansible-role')
    if is_ansible_toolbox_installed:
        print('ansible toolbox already installed')
        return

    shell_call('pip3 install --user ansible-toolbox')


def get_opt_str(args):
    opts = '--diff'
    if args.tags:
        opts += ' --tags ' + args.tags
    if args.skip_tags:
        opts += ' --skip-tags ' + args.skip_tags
    if not args.install:
        opts += ' --check'
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
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
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
