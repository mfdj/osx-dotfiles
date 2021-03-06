#!/usr/bin/env bash

require 'functions/input-helpers'
require 'functions/plist-helpers'


# Set ComputerName, HostName, LocalHostName
# http://ilostmynotes.blogspot.com/2012/03/computername-vs-localhostname-vs.html
echo 'Ensuring ComputerName, HostName, LocalHostName are set'
[[ -f $DOTFILES_DIR/local/machine-name ]] || {
   machine_name=$(scutil --get ComputerName)
   promptfor machine_name
   sudo -i bash -c "
      scutil --set ComputerName $machine_name &&
      scutil --set HostName $machine_name &&
      scutil --set LocalHostName $machine_name" \
   && echo "$machine_name" > "$DOTFILES_DIR/local/machine-name"
}


echo 'Ensuring Dock auto-hide'
autohide_dock=$(defaults read com.apple.dock autohide 2> /dev/null)
[[ $autohide_dock != 1 ]] \
   && defaults write com.apple.dock autohide -bool true \
   && killall Dock


echo 'Ensuring iTunes Half Star'
itunes_half_star=$(defaults read com.apple.iTunes allow-half-stars 2> /dev/null)
[[ $itunes_half_star != 1 ]] && defaults write com.apple.iTunes allow-half-stars -bool TRUE


echo 'Ensuring mission-control symbolichotkeys are disabled (requires restart)'
for n in {32..37} {60..63}; do
   plist_disable ~/Library/Preferences/com.apple.symbolichotkeys.plist \
      :AppleSymbolicHotKeys:$n
done
defaults read com.apple.symbolichotkeys > /dev/null # http://stackoverflow.com/a/26564334/934195


echo 'Ensuring Terminal secure-keyboard-entry and option-as-meta'
# NOTE: security.stackexchange.com/questions/47749/how-secure-is-secure-keyboard-entry-in-mac-os-xs-terminal
[ "$(defaults read com.apple.Terminal SecureKeyboardEntry)" != 1 ] && {
   defaults write com.apple.Terminal SecureKeyboardEntry -bool true
   defaults write com.apple.Terminal useOptionAsMetaKey -bool true
   defaults read com.apple.Terminal > /dev/null
}

# use Homebrew installed bash (maybe zsh/fish someday)
preferred_shell=/usr/local/bin/bash
[[ -f $preferred_shell ]] && {
   echo "Ensuring use of preferred shell: $preferred_shell"

   if ! grep "$preferred_shell" /etc/shells -q; then
      echo "• adding '$preferred_shell' to /etc/shells"
      echo "• changing shell to '$preferred_shell'"
      echo '# dotfiles-setup added:' > ~/new-etc-shells
      { echo "$preferred_shell"; echo; cat /etc/shells; } >> ~/new-etc-shells

      user=$(whoami)
      sudo -s -- mv ~/new-etc-shells /etc/shells && {
         chsh -s "$preferred_shell" "$user" && {
            echo 'start new session to use changed shell'
         }
      }
   elif [[ $SHELL != "$preferred_shell" ]]; then
      echo "• changing shell to '$preferred_shell'"
      chsh -s $preferred_shell && {
         echo 'start new session to use changed shell'
      }
   fi

   echo -n "$SHELL — " && $SHELL --version | head -n 1
}
