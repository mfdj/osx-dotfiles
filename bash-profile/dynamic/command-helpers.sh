#!/usr/bin/env bash

### shell-completions, see: /usr/local/etc/bash_completion.d
if brew --prefix git &> /dev/null; then
   find /usr/local/etc/bash_completion.d -name '*git*' -exec echo source '{}' \;
fi

### n, node.js version manager
# startup-cost: 0
[[ -d ~/.n ]] && {
   echo "export N_PREFIX=${HOME}/.n"
   echo "PATH+=:${N_PREFIX}/bin"  # Added by n-install (see http://git.io/n-install-repo).
}

# nvm startup-cost: 0m0.590s — ~80% of the time of this module
# [[ -f ~/.nvm/nvm.sh          ]] && echo source ~/.nvm/nvm.sh
# n completions startup-cost: 0m0.076s
# [[ -r ~/.nvm/bash_completion ]] && echo source ~/.nvm/bash_completion
# nvm-total startup-cost: 0m0.640s

### pyenv
### disable until I figure out how I want to setup python2/python3 side-by-side;
### it's doable https://github.com/yyuu/pyenv/blob/master/COMMANDS.md#pyenv-global-advanced
### but at low priority to my current setup (homebrew handles it fine for my current needs)
# static startup-cost: 0m.077s
# startup-cost: 0m.121s (+0.05s)
#command -v pyenv > /dev/null && echo 'eval "$(pyenv init -)"'

### rbenv
# static startup-cost: 0m0.068s
# startup-cost: 0m0.097s (+0.03s)
command -v rbenv > /dev/null && echo 'eval "$(rbenv init -)"'