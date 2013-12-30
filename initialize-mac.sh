#!/bin/sh
# HOMEBREW_GITHUB_API_TOKEN=

cd $(dirname $0)
 
echo "Asking for the administrator password upfront... "
sudo -v

read -p "Install xcode command line tools? (y/n) "
if [ $REPLY == "y" ]; then
    xcode-select --install
    read -p "Click any key to continue once xcode finishes installing command line tools... "
fi

read -p "Remove and deactivate Mac OSX Dashboard? (y/n) "
if [ $REPLY == "y" ]; then
    defaults write com.apple.dashboard mcx-disabled -boolean YES;killall Dock
fi

read -p "Use my .bash_aliases .bash_profile .gitconfig? (y/n) "
if [ $REPLY == "y" ]; then
    cp -i .bash_aliases ~
    cp -i .bash_profile ~
    cp -i .gitconfig ~
fi

brew_path=`which brew`
if [[ ! -f $brew_path ]]; then
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
    source ~/.bash_profile
fi

brew tap phinze/homebrew-cask
brew install brew-cask
brew install ack
brew install htop
brew install wget

read -p "Do you want to install any developer tools such as git, heroku-toolbelt, janus, maven, nvm, rb-env? (y/n) "
if [ $REPLY == "y" ]; then
    brew install git
    brew install heroku-toolbelt
    curl -Lo- https://bit.ly/janus-bootstrap | bash
    brew install maven
    curl https://raw.github.com/creationix/nvm/master/install.sh | sh
    brew install rbenv ruby-build
    echo export RBENV_ROOT=/usr/local/var/rbenv >> ~/.bash_profile
fi

read -p "Do you want to setup your github account? (y/n) "
if [ $REPLY == "y" ]; then
	
	echo "Installing git https credential helper... "
    curl -s -O \
      http://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
    chmod u+x git-credential-osxkeychain
    sudo mv git-credential-osxkeychain \
      "$(dirname $(which git))/git-credential-osxkeychain"
    git config --global credential.helper osxkeychain

    echo "You name (for commits): "
    read GIT_NAME
    git config --global user.name ${GIT_NAME}

    echo "You email (for commits): "
    read GIT_EMAIL
    git config --global user.email ${GIT_EMAIL}
    if [ ! -f ~/.ssh/id_rsa ]; then
        read -p "Do you want to generate new ssh keys with this email? (y/n) "
        if [ $REPLY == "y" ]; then
            ssh-keygen -t rsa -C ${GIT_EMAIL}
            ssh-add id_rsa
        fi
    fi
fi

read -p "Do you want to setup a local mysql database? (y/n) "
if [ $REPLY == "y" ]; then
    brew install mysql
    mkdir -p ~/Library/LaunchAgents
    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
    launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
fi

read -p "Do you want to install some third party tools? (y/n) "
if [ $REPLY == "y" ]; then
    # echo export ${HOMEBREW_GITHUB_API_TOKEN}
    sh brew-cask.sh
fi

# Verify #
brew doctor
