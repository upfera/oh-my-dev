#!/bin/bash

# Install ZSH with plugins
sudo apt -y install zsh

# Setup config files
if [[ ! -f "$HOME/.zshrc" ]]; then
    cp "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)/dot_files/.zshrc" "$HOME/.zshrc"
fi

mkdir -p ~/.zsh
touch ~/.zsh/.zsh_history

# Support for left/right arrow keys movement in terminal
grep -qxF 'bindkey "\e[1;5C" forward-word' "$HOME/.zshrc" || echo 'bindkey "\e[1;5C" forward-word' >> "$HOME/.zshrc"
grep -qxF 'bindkey "\e[1;5D" backward-word' "$HOME/.zshrc" || echo 'bindkey "\e[1;5D" backward-word' >> "$HOME/.zshrc"

sudo chsh -s $(which zsh) $(whoami)
