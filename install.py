#!/usr/bin/python
import os

SCRIPT_DIR = os.getcwd()

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


