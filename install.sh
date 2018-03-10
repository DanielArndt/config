#!/bin/bash

if ! hash ansible-playbook > /dev/null; then
	sudo apt-get update && sudo apt-get install -y python python-pip
	sudo pip install -U pip setuptools
	sudo pip install ansible || { echo "Error: \`pip install ansible\`" && exit 1; }
fi

role=$1

if [[ -n "${role}" ]]; then
	if ! hash ansible-role > /dev/null; then
		sudo pip install ansible-toolkit
	fi
	(cd ansible && ansible-role -i "localhost," -c local $role)
else
	ansible-playbook -i "localhost," -c local ansible/master.yml 
fi
