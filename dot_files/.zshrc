export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:/snap/bin:/opt/bin:$PATH

export ZSH=$HOME/.zsh

export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=$ZSH/.zsh_history

export COLORTERM=truecolor
export TERM=xterm-256color

setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

[ -f ~/.zsh_aliases ] && . ~/.zsh_aliases;
[ -f ~/.zsh_windows_aliases ] && . ~/.zsh_windows_aliases