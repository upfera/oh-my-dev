#!/bin/bash

# Create docker executable and mute "nodocker" warning:
echo '#!/bin/sh
[ -e /etc/containers/nodocker ] || \
echo "Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg." >&2
exec podman "$@"' | sudo tee /usr/local/bin/docker

sudo chmod +x /usr/local/bin/docker
sudo touch /etc/containers/nodocker

# Create podman compose executable
echo '#!/bin/bash
exec podman-compose "$@"' | sudo tee /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
