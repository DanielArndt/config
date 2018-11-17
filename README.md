Installation
------------

First, install git and python if they aren't already installed.

```bash
    sudo apt-get install git python3 python3-distutils
```

Then, clone the repository into your home directory.

_**Note:** This script assumes that the config scripts are installed in your
home directory. (ie. $HOME/config)_

```bash
    cd ~
    git clone https://github.com/DanielArndt/config.git
```

Finally, run the installation script.

```bash
     python3 config/install.py
```

That is all.
