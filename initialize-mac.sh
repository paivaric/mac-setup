#!/bin/sh

GIT_COMPLETION_SCRIPT_LOCATION="https://raw.github.com/git/git/v1.8.5.2/contrib/completion/git-completion.bash"
# HOMEBREW_GITHUB_API_TOKEN=

cd $(dirname $0)

read -p "Install xcode command line tools? (y/n) "
if [ $REPLY == "y" ]; then
    xcode-select --install
    read -p "Click any key to continue once xcode finishes installing command line tools... "
fi

read -p "Remove and deactivate Mac OSX Dashboard? (y/n) "
if [ $REPLY == "y" ]; then
    defaults write com.apple.dashboard mcx-disabled -boolean YES;killall Dock
fi

# mkdir ~/code ~/tools ~/.ssh
read -p "Use my .bash_aliases .bash_profile .gitconfig? (y/n) "
if [ $REPLY == "y" ]; then
    cp -i .bash_aliases ~
    cp -i .bash_profile ~
    cp -i .gitconfig ~
fi

echo "Installing system tools... "
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew tap phinze/homebrew-cask
brew install brew-cask
brew install ack
brew install htop
brew install wget

read -p "Do you want to install any developer tools such as git, heroku-toolbelt, janus, maven, nvm, rb-env? "
if [ $REPLY == "y" ]; then
    brew install git
    brew install heroku-toolbelt
    curl -Lo- https://bit.ly/janus-bootstrap | bash
    brew install maven
    curl https://raw.github.com/creationix/nvm/master/install.sh | sh
    brew install rbenv ruby-build
    echo export RBENV_ROOT=/usr/local/var/rbenv >> ~/.bash_profile
fi

read -p "Do you want to setup your github account?"
if [ $REPLY == "y" ]; then
    curl -s -O \
      http://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
    chmod u+x git-credential-osxkeychain
    sudo mv git-credential-osxkeychain \
      "$(dirname $(which git))/git-credential-osxkeychain"
    git config --global credential.helper osxkeychain

    curl ${GIT_COMPLETION_SCRIPT_LOCATION} -o ~/.git-completion.bash
    echo ". ~/.git-completion.bash" >> ~/.bash_profile

    echo "You name (for commits): "
    read GIT_NAME
    git config --global user.name ${GIT_NAME}

    echo "You email (for commits): "
    read GIT_EMAIL
    git config --global user.email ${GIT_EMAIL}
    if [ ! -f ~/.ssh/id_rsa ]; then
        read -p "Do you want to generate new ssh keys with this email? "
        if [ $REPLY == "y" ]; then
            ssh-keygen -t rsa -C ${GIT_EMAIL}
            ssh-add id_rsa
        fi
    fi
fi

read -p "Do you want to setup a local mysql database? "
if [ $REPLY == "y" ]; then
    brew install mysql
    mkdir -p ~/Library/LaunchAgents
    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
    launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
fi

read -p "Do you want to install some third party tools? "
if [ $REPLY == "y" ]; then
    # echo export ${HOMEBREW_GITHUB_API_TOKEN}
    brew cask install caffeine
    brew cask install coconutbattery
    brew cask install iterm2
fi

#brew cask install acorn
#brew cask install alfred
#brew cask install app-cleaner
#brew cask install dropbox
#brew cask install eclipse-ide
#brew cask install f-lux
#brew cask install filezilla
#brew cask install google-chrome
#brew cask install google-hangouts
#brew cask install j-downloader
#brew cask install logitech-unifying
#brew cask install name-changer
#brew cask install seashore
#brew cask install skype
#brew cask install sublime-text
#brew cask install sourcetree
#brew cask install steam
#brew cask install team-viewer
#brew cask install textmate
#brew cask install true-crypt
#brew cask install vagrant
#brew cask install virtualbox
#brew cask install vlc

# Verify #
brew doctor
