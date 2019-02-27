0=${(%):-%N}

lastupdate=${0:A:h}/lastupdate
[[ -f "$lastupdate" ]] || touch "$lastupdate"

function file-age {
  local file_created_time=`date -r "$1" +%s`
  local time_now=`date +%s`
  echo "$[ ${time_now} - ${file_created_time} ]"
}

# history
SAVEHIST=50000 # Number of entries
HISTSIZE=50000
HISTFILE=$ZDOTDIR/zsh_history # File
setopt APPEND_HISTORY # Don't erase history
setopt EXTENDED_HISTORY # Add additional data to history like timestamp
setopt INC_APPEND_HISTORY # Add immediately
setopt HIST_FIND_NO_DUPS # Don't show duplicates in search
setopt HIST_IGNORE_SPACE # Don't preserve spaces. You may want to turn it off
setopt NO_HIST_BEEP # Don't beep
setopt SHARE_HISTORY # Share history between session/terminals

# add the zsh calculator
autoload -Uz zcalc

# helpful aliases
alias cd..='cd ..'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias reload="source $ZDOTDIR/.zshrc"

# cdpath will let you treat subdirs of this list as directly avalailable from
# whatever directory you are in
setopt auto_cd
cdpath=(
  $HOME/Documents
)

# `ls` after `cd`
# https://stackoverflow.com/questions/3964068/zsh-automatically-run-ls-after-every-cd
function chpwd() {
    emulate -L zsh
    ls -F
}
