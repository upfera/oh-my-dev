#!/bin/bash

sudo apt-get update
sudo apt-get install apt-transport-https wget --yes
wget -O /tmp/kubecolor.deb https://kubecolor.github.io/packages/deb/pool/main/k/kubecolor/kubecolor_$(wget -q -O- https://kubecolor.github.io/packages/deb/version)_$(dpkg --print-architecture).deb
sudo dpkg -i /tmp/kubecolor.deb
sudo apt update