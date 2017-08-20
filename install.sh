if ! hash salt-call > /dev/null; then
    curl -L https://bootstrap.saltstack.com -o bootstrap_salt.sh
    sudo sh bootstrap_salt.sh
fi

sudo salt-call --file-root=salt --local state.highstate
