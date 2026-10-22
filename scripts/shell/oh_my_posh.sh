#!/bin/bash

sudo apt -y install unzip

# Oh my posh:

curl -s https://ohmyposh.dev/install.sh | bash -s

# Add oh my posh to bash
echo -e "export PATH=\$PATH:/home/$(whoami)/.local/bin" >> ~/.bashrc
echo 'eval "$(oh-my-posh init --config '~/.cache/oh-my-posh/themes/atomic.omp.json' bash)"' >> ~/.bashrc

# Add oh-my-posh to .zshrc
echo 'eval "$(oh-my-posh init --config '~/.cache/oh-my-posh/themes/atomic.omp.json' zsh)"' >> ~/.zshrc
