#!/bin/bash

if ! hash ansible-playbook > /dev/null; then
	sudo apt-get update && sudo apt-get install -y python python-pip
	sudo pip install -U pip setuptools
	sudo pip install ansible || { echo "Error: \`pip install ansible\`" && exit 1; }
fi

ansible-playbook -i "localhost," -c local ansible/playbook.yml 
