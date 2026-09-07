#!/bin/bash

# Podman
sudo apt update
sudo apt -y upgrade
sudo apt-get -y install podman
sudo mount -o remount,shared / /

# enable auto run
systemctl --user start podman.socket
systemctl --user enable podman.socket

# Podman Compose
sudo apt -y install python3-dotenv
sudo curl -o /usr/local/bin/podman-compose https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py
sudo chmod +x /usr/local/bin/podman-compose

# Add repository
echo -e "[registries.search]\nregistries = ['docker.io']" | sudo tee -a /etc/containers/registries.conf

# IPv4 support for windows
echo -e "wsl" | sudo tee -a /etc/containers/podman-machine