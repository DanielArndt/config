import click
import io
import os
import requests
import shlex
import subprocess

CALL_DIR = os.getcwd()
GITHUB_SSH_URL = 'git@github.com:'

def shell_call(command_str, cwd=CALL_DIR, **kwargs):
    cmd = shlex.split(command_str)
    return subprocess.check_output(cmd, cwd=CALL_DIR, **kwargs)


def github_parse_repo(remote_name):
    output = shell_call('git config --get remote.{}.url'.format(remote_name))
    output = output.decode('UTF-8')
    if not output.startswith(GITHUB_SSH_URL):
        return None
    path = output.rstrip()[len(GITHUB_SSH_URL):]
    (account, repo_name) = path.split('/', 2)
    return repo_name


def git_add_remote(remote_name, remote_url):
    output = shell_call('git remote add {} {}'.format(remote_name, remote_url))
    return output.decode('UTF-8')

@click.group()
def main():
	pass


@main.group()
def remote():
    ''' Modify git remotes '''
    pass


@remote.command()
@click.argument('username')
def add(username):
    ''' Add a git remote '''
    output = shell_call('git remote')
    remotes = output.decode('UTF-8').splitlines()
    if 'origin' in remotes:
        repo_name = github_parse_repo('origin')
        url = GITHUB_SSH_URL + username + '/' + repo_name
    else:
        for remote in remotes:
            repo_name = github_parse_repo(remote)
            if not repo_name:
                continue
            url = GITHUB_SSH_URL + username + '/' + repo_name

    git_add_remote(username, url)


if __name__ == '__main__':
    main()
