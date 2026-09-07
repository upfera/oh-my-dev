#!/bin/bash

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.zsh/plugins/fzf

# fzf key bindings and completions
[ -f ~/.zsh/plugins/fzf/install ] && ~/.zsh/plugins/fzf/install --all --key-bindings --completion