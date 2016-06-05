#!/usr/bin/env bash

require 'functions/brew-helpers'
require 'functions/ensure-symlink'

# + + + + + + + + + + + + + + + +
# +  XCode Command Line Tools   +
# + + + + + + + + + + + + + + + +

echo Ensuring XCode Command Line Tools
# if xcode has already installed it will evaulate to false
if xcode-select --install 2> /dev/null; then
   # is there is a way to check this w/o sudo?
   sudo xcodebuild -license 2> /dev/null
fi

# + + + + + + + + + + + + + + +
# +         Homebrew          +
# +  see configs/brew-files   +
# + + + + + + + + + + + + + + +

echo Ensuring Homebrew
[[ ! -f /usr/local/bin/brew ]] &&
   ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# ! command -v brew > /dev/null && {
#    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# }

brewfile() {
   require "configs/brewfiles/$1"
   echo
}

[[ $DO_UPDATES ]] && brew update

# homebrew minimum
brewfile core

# homebrew optional
[[ $DO_OPTIONAL             ]] && brewfile optional
[[ $DO_CASK                 ]] && brewfile cask-core
[[ $DO_CASK && $DO_OPTIONAL ]] && brewfile cask-optional

# homebrew maintenance
# cask upgrade conversation: https://github.com/caskroom/homebrew-cask/issues/16033
[[ $DO_UPDATES ]] && brew upgrade --all
[[ $DO_CLEAN   ]] && { brew cleanup; brew cask cleanup; cask_deep_clean; }

# + + + + + + + + + + + + + + + +
# +         Composer            +
# +  getcomposer.org/download   +
# + + + + + + + + + + + + + + + +

# NOTE: Composer should install after Homebrew because /usr/local/ is created by Homebrew

echo Ensuring Composer
if [[ ! -f /usr/local/bin/composer ]]; then
   php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
   # sha updated 2016-04-02
   composerSHA384=7228c001f88bee97506740ef0888240bd8a760b046ee16db8f4095c0d8d525f2367663f22a46b48d072c816e7fe19959
   php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '${composerSHA384}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
   if [[ -f composer-setup.php ]]; then
      php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer
      php -r "unlink('composer-setup.php');"
   else
      echo "composer-setup verification issue (sha384: ${composerSHA384}"
      echo 'check https://composer.github.io/pubkeys.html'
   fi
elif [[ $DO_UPDATES ]]; then
   composer selfupdate
else
   composer --version
fi

# + + + + + + + + + + + + + + + + + + +
# +  n (simple node version manager)  +
# +  github.com/tj/n                  +
# + + + + + + + + + + + + + + + + + + +

echo Ensuring N
if [[ ! -d ~/.n ]]; then
   git clone https://github.com/tj/n ~/.n
elif [[ $DO_UPDATES ]]; then
   cd ~/.n
   git pull
fi
