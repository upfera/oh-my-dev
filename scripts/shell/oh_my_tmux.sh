#!/bin/bash

# Clone the gpakosz repo into the home directory
git clone --single-branch https://github.com/gpakosz/.tmux.git "$HOME/.tmux"

# Create a symlink to .tmux.conf in the home directory
ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"

# Copy the local config file to home
cp "$HOME/.tmux/.tmux.conf.local" "$HOME/"