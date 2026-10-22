#!/bin/bash

# Be cautious! Password-less sudo!
echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$(whoami)
sudo chmod 440 /etc/sudoers.d/$(whoami)