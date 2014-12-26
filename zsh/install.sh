# Install zsh
sudo apt-get install zsh

# Clone the antigen repo, a zsh plugin manager
git clone https://github.com/zsh-users/antigen.git ~/config/zsh/antigen

# Link the zshrc
ln -i -s ~/config/zsh/.zshrc ~/.zshrc

# Change shell to zsh and launch it
chsh -s /bin/zsh
if [ $SHELL != "/bin/zsh" ]; then
    echo "Switching to zsh"
    zsh
fi

