#!/bin/bash
set -e

sudo mkdir -p /var/snap/microk8s/current/args/certs.d/docker.io

sudo tee /var/snap/microk8s/current/args/certs.d/docker.io/hosts.toml > /dev/null <<EOF
server = "https://registry-1.docker.io"

[host."http://localhost:32000"]
  capabilities = ["pull", "resolve"]
EOF

sudo mkdir -p /var/snap/microk8s/current/args/certs.d/quai.io
sudo tee /var/snap/microk8s/current/args/certs.d/quai.io/hosts.toml > /dev/null <<EOF
server = "https://quay.io"

[host."http://localhost:32000"]
  capabilities = ["pull", "resolve"]
EOF

sudo mkdir -p /var/snap/microk8s/current/args/certs.d/localhost:32000

sudo tee /var/snap/microk8s/current/args/certs.d/localhost:32000/hosts.toml > /dev/null <<EOF
server = "https://registry-1.docker.io"

[host."http://localhost:32000"]
  capabilities = ["pull", "resolve", "push"]
  skip_verify = true
EOF

## Restart microk8s by applying changes
#sudo snap restart microk8s
